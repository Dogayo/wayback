import 'dart:io';

import 'source_file.dart';

/// Longest a screen file may get before its parts move to `view/widgets/`.
const maxScreenLines = 250;

/// Material widgets that have a design-system counterpart (Wb*).
const _rawMaterial = {
  'ElevatedButton': 'WbButton',
  'TextButton': 'WbButton(variant: tertiary)',
  'OutlinedButton': 'WbButton(variant: secondary)',
  'FilledButton': 'WbButton',
  'IconButton': 'WbIconButton',
  'AppBar': 'WbAppBar',
  'AlertDialog': 'WbDialogs',
  'SimpleDialog': 'WbDialogs',
  'ListTile': 'WbListItem',
  'Card': 'WbCard',
  'Chip': 'WbChip',
  'Switch': 'WbSwitch',
  'Checkbox': 'WbCheckbox',
  'Radio': 'WbRadio',
  'TextField': 'WbTextField',
  'TextFormField': 'WbTextField',
  'SnackBar': 'WbSnackbar.show',
  'LinearProgressIndicator': 'WbProgress',
  'CircularProgressIndicator': 'WbProgress',
};

/// Files the screen rules apply to: screens and widgets of features and the
/// shared widgets in core.
bool isViewFile(String path) =>
    RegExp(r'/view/(screens|widgets)/').hasMatch(path) ||
    path.contains('/core/widgets/');

/// Every screen rule over [files]; [testExists] answers whether a test file
/// is present (the real file system by default).
List<Violation> checkScreenRules(
  List<SourceFile> files, {
  bool Function(String path)? testExists,
}) => [
  for (final file in files)
    if (isViewFile(file.path)) ...[
      ...noHardcodedText(file),
      ...designTokens(file),
      ...designSystemComponents(file),
      ...actionListeners(file),
      ...thinScreens(file),
      ...screenSize(file),
      ...screenHasTest(file, testExists ?? (path) => File(path).existsSync()),
    ],
];

/// Everything the user reads comes from `context.l10n`: any non-empty
/// string literal in a view is suspect, even `'—'` or a hand-built
/// `'$lat, $lon'`. Directives and widget keys are exempt.
List<Violation> noHardcodedText(SourceFile file) {
  final source = stripComments(file.content)
      .replaceAll(
        RegExp(r'''^\s*(import|export|part)\s.*$''', multiLine: true),
        '',
      )
      .replaceAll(
        RegExp(
          r'''\b(Value|Object|Global)?Key(<\w+>)?\(\s*('[^']*'|"[^"]*")''',
        ),
        '',
      );
  final literal = RegExp(r'''('(?:[^'\\\n]|\\.)+'|"(?:[^"\\\n]|\\.)+")''');
  return [
    for (final match in literal.allMatches(source))
      Violation(
        'l10n-only',
        file.path,
        'string literal ${match[0]}; take user text from context.l10n and '
            'formatting from core/utils',
      ),
  ];
}

/// Colors, sizes and spacing come from tokens (wbColors, WbSpacing,
/// WbRadius, WbIconSize), never from literals. Zero is allowed.
List<Violation> designTokens(SourceFile file) {
  final source = stripComments(file.content);
  final checks = {
    r'\bColor\(\s*0x': 'a raw Color; use context.wbColors',
    r'\bColors\.(?!transparent\b)\w+': 'Colors.*; use context.wbColors',
    r'\bTextStyle\(': 'a raw TextStyle; use context.wbText',
    r'\bEdgeInsets\.\w+\([^)]*\b[1-9]\d*(\.\d+)?\b':
        'a number in EdgeInsets; use WbSpacing',
    r'\b(width|height|size|fontSize|radius|spacing):\s*[1-9]\d*(\.\d+)?\b':
        'a number for a size; use WbSpacing / WbIconSize / WbRadius',
    r'\bRadius\.circular\(\s*[1-9]': 'a raw radius; use WbRadius',
  };
  return [
    for (final MapEntry(key: pattern, value: message) in checks.entries)
      for (final match in RegExp(pattern).allMatches(source))
        Violation('design-tokens', file.path, '$message (${match[0]})'),
  ];
}

/// A Material widget with a Wb* counterpart is not used directly.
List<Violation> designSystemComponents(SourceFile file) {
  final source = stripComments(file.content);
  return [
    for (final MapEntry(key: widget, value: replacement)
        in _rawMaterial.entries)
      if (RegExp('(?<![\\w.])$widget\\(').hasMatch(source))
        Violation(
          'design-system',
          file.path,
          '$widget is a raw Material widget; use $replacement',
        ),
  ];
}

/// The result of an action always goes through `ActionResultListener`, which adds
/// the haptic and the error: a plain listener is how one gets forgotten.
List<Violation> actionListeners(SourceFile file) => [
  if (RegExp(
    r'BlocListener<\w+,\s*ActionState<',
  ).hasMatch(stripComments(file.content)))
    Violation(
      'action-result-listener',
      file.path,
      'a BlocListener on an ActionState; use ActionResultListener',
    ),
];

/// Screens show state and send events: no DI, no repositories, no bloc
/// creation, no calculations. Error-code constants are fine.
List<Violation> thinScreens(SourceFile file) {
  final source = stripComments(file.content);
  final checks = {
    r'\bcontext\.di\b|package:app_di/':
        'reads DI; blocs get dependencies '
        'in the router',
    r'\b\w+Repository\b': 'touches a repository; go through a bloc',
    r"import\s+'package:wayback/features/\w+/data/": 'imports data/',
    r'\b(Multi)?BlocProvider\(':
        'creates blocs; they are created in the '
        'router',
    r'\b(distanceMeters|bearingDegrees|arrowRotationDegrees)\(|geo_math\.dart':
        'calculates; calculations belong in a bloc or core/utils',
  };
  return [
    for (final MapEntry(key: pattern, value: message) in checks.entries)
      if (RegExp(pattern).hasMatch(source))
        Violation('thin-screens', file.path, message),
  ];
}

/// A screen file stays readable; parts move to `view/widgets/`.
List<Violation> screenSize(SourceFile file) {
  if (!file.path.contains('/view/screens/')) return const [];
  final lines = '\n'.allMatches(file.content).length;
  return [
    if (lines > maxScreenLines)
      Violation(
        'screen-size',
        file.path,
        '$lines lines; split parts into view/widgets/ (max $maxScreenLines)',
      ),
  ];
}

/// Every screen has a widget test at the mirrored path.
List<Violation> screenHasTest(
  SourceFile file,
  bool Function(String path) testExists,
) {
  if (!file.path.contains('/view/screens/')) {
    return const [];
  }
  final test = file.path
      .replaceFirst(RegExp('^lib/'), 'test/')
      .replaceFirst(RegExp(r'\.dart$'), '_test.dart');
  return [
    if (!testExists(test))
      Violation('screen-test', file.path, 'no widget test at $test'),
  ];
}
