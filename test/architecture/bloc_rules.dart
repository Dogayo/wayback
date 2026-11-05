import 'source_file.dart';

/// Base blocs from `lib/core/bloc/`; every feature bloc extends one of them
/// or `Bloc` itself with its own event and state parts.
const baseBlocs = {'DataBloc', 'ActionBloc', 'ListBloc'};

/// Concrete state classes of the base blocs. The view handles states only
/// through `map` / `mapOrElse` / `mapOrNull`, so these names stay out of it.
final _baseStateNames = RegExp(
  r'\b(Data(Initial|Loading|Success|Failure)|'
  r'Action(Idle|InProgress|Success|Failure)|'
  r'List(Initial|Loading|Empty|Loaded|Failure))\b',
);

final _blocClass = RegExp(r'class\s+(\w+)(?:<[^{]*?>)?\s+extends\s+(\w+)\s*<');

/// Every rule, run over [files]; an empty list means the gate passes.
List<Violation> checkBlocRules(List<SourceFile> files) => [
  for (final file in files) ...[
    ...noCubit(file),
    ...blocFileLayout(file),
    ...blocParts(file),
    ...partFiles(file),
    ...stateMapMethods(file),
    ...sealedEvents(file),
    ...blocImports(file),
    ...noBlocInDi(file),
    ...viewUsesMapMethods(file),
  ],
];

/// Blocs only: a Cubit hides events, so actions are not traceable.
/// Also catches cubits that extend another cubit, by their name.
List<Violation> noCubit(SourceFile file) {
  final source = stripComments(file.content);
  final cubit =
      RegExp(r'extends\s+Cubit\s*<').hasMatch(source) ||
      RegExp(r'class\s+\w+Cubit\b').hasMatch(source);
  return [
    if (cubit)
      Violation(
        'no-cubit',
        file.path,
        'use a Bloc (DataBloc, ActionBloc, ListBloc or Bloc with event and '
            'state parts), not a Cubit',
      ),
  ];
}

/// One bloc per file, named `*_bloc.dart`; in a feature it lives in
/// `view/bloc/`, and it extends a base bloc or `Bloc` itself.
List<Violation> blocFileLayout(SourceFile file) {
  final blocs = [
    for (final match in _blocClass.allMatches(stripComments(file.content)))
      if (match[2] == 'Bloc' || baseBlocs.contains(match[2]))
        (name: match[1]!, base: match[2]!),
  ];
  if (blocs.isEmpty) return const [];
  final inFeature = file.path.contains('/features/');
  return [
    if (blocs.length > 1)
      Violation(
        'one-bloc-per-file',
        file.path,
        '${blocs.map((b) => b.name).join(', ')} share a file',
      ),
    if (!basename(file.path).endsWith('_bloc.dart'))
      Violation(
        'bloc-file-name',
        file.path,
        '${blocs.first.name} must live in a *_bloc.dart file',
      ),
    if (inFeature && !file.path.contains('/view/bloc/'))
      Violation(
        'bloc-location',
        file.path,
        '${blocs.first.name} must live in view/bloc/ of its feature',
      ),
    for (final bloc in blocs)
      if (!bloc.name.endsWith('Bloc'))
        Violation('bloc-name', file.path, '${bloc.name} must end with "Bloc"'),
  ];
}

/// A bloc on `Bloc` directly keeps events and states in
/// `<name>_event.dart` and `<name>_state.dart`, joined with `part`.
List<Violation> blocParts(SourceFile file) {
  final source = stripComments(file.content);
  final direct = _blocClass
      .allMatches(source)
      .any((match) => match[2] == 'Bloc');
  if (!direct) return const [];
  final stem = basename(file.path).replaceFirst(RegExp(r'_bloc\.dart$'), '');
  return [
    for (final part in ['${stem}_event.dart', '${stem}_state.dart'])
      if (!source.contains("part '$part';"))
        Violation('bloc-parts', file.path, "missing part '$part'"),
  ];
}

/// Event and state files next to a bloc are parts of it, nothing else.
List<Violation> partFiles(SourceFile file) {
  final name = basename(file.path);
  final match = RegExp(r'^(\w+)_(event|state)\.dart$').firstMatch(name);
  if (match == null || !file.path.contains('/bloc/')) return const [];
  final owner = '${match[1]}_bloc.dart';
  final source = stripComments(file.content).trim();
  return [
    if (!source.startsWith("part of '$owner';"))
      Violation('part-of', file.path, "must start with part of '$owner';"),
    if (RegExp(r'^import\s', multiLine: true).hasMatch(source))
      Violation(
        'part-of',
        file.path,
        'a part file cannot import; '
            'imports belong to $owner',
      ),
  ];
}

/// The root of a state hierarchy offers `map`, `mapOrElse` and `mapOrNull`,
/// so the view never needs type checks.
List<Violation> stateMapMethods(SourceFile file) {
  if (!basename(file.path).endsWith('_state.dart')) return const [];
  final source = stripComments(file.content);
  final roots = RegExp(r'sealed\s+class\s+(\w+)').allMatches(source);
  return [
    for (final root in roots)
      for (final method in ['map', 'mapOrElse', 'mapOrNull'])
        if (!RegExp('\\b$method\\s*<').hasMatch(source))
          Violation(
            'state-map-methods',
            file.path,
            '${root[1]} must declare $method<R>()',
          ),
  ];
}

/// Events form a sealed hierarchy, so every handler covers all of them.
List<Violation> sealedEvents(SourceFile file) {
  if (!basename(file.path).endsWith('_event.dart')) return const [];
  return [
    if (!RegExp(
      r'sealed\s+class\s+\w+Event\b',
    ).hasMatch(stripComments(file.content)))
      Violation(
        'sealed-events',
        file.path,
        'the root event must be a sealed class named *Event',
      ),
  ];
}

/// Blocs talk to repositories from `domain`, never to `data`, and know
/// nothing about widgets.
List<Violation> blocImports(SourceFile file) {
  if (!basename(file.path).endsWith('_bloc.dart')) return const [];
  final source = stripComments(file.content);
  return [
    if (RegExp(
      r"import\s+'package:wayback/features/\w+/data/",
    ).hasMatch(source))
      Violation('bloc-imports', file.path, 'a bloc must not import data/'),
    if (RegExp(
      r"import\s+'package:flutter/(material|widgets|cupertino)\.dart'",
    ).hasMatch(source))
      Violation('bloc-imports', file.path, 'a bloc must not import widgets'),
  ];
}

/// Blocs are created in BlocProvider, never registered in DI.
List<Violation> noBlocInDi(SourceFile file) {
  if (!file.path.contains('/app/dependencies/')) return const [];
  return [
    if (RegExp(r'\b\w*(Bloc|Cubit)\b').hasMatch(stripComments(file.content)))
      Violation(
        'no-bloc-in-di',
        file.path,
        'blocs are created in BlocProvider, not registered in app_di',
      ),
  ];
}

/// Screens and widgets read base-bloc states only through the map methods.
List<Violation> viewUsesMapMethods(SourceFile file) {
  final isView =
      RegExp(r'/view/(screens|widgets)/').hasMatch(file.path) ||
      file.path.contains('/core/widgets/');
  if (!isView) return const [];
  final used = _baseStateNames
      .allMatches(stripComments(file.content))
      .map((m) => m[0])
      .toSet();
  return [
    if (used.isNotEmpty)
      Violation(
        'view-map-methods',
        file.path,
        'use map / mapOrElse / mapOrNull instead of ${used.join(', ')}',
      ),
  ];
}
