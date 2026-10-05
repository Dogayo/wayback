import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file in this package.
///
/// `flutter test` renders text with the Ahem test font, which turns every
/// glyph into a box. Goldens need real shapes, so the Roboto and Material
/// Icons files that ship with the Flutter SDK are registered first. The app
/// ships no font of its own (see DESIGN_SYSTEM.md), so Roboto is also aliased
/// to the Cupertino system families that iOS-platform themes ask for.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadSdkFonts();
  await testMain();
}

const _robotoFiles = [
  'roboto-regular.ttf',
  'roboto-italic.ttf',
  'roboto-medium.ttf',
  'roboto-bold.ttf',
];

const _robotoAliases = [
  'Roboto',
  'CupertinoSystemText',
  'CupertinoSystemDisplay',
  '.SF UI Text',
  '.SF UI Display',
  '.AppleSystemUIFont',
];

Future<void> _loadSdkFonts() async {
  final fonts = _materialFontsDirectory();
  for (final family in _robotoAliases) {
    final loader = FontLoader(family);
    for (final file in _robotoFiles) {
      loader.addFont(_read(fonts, file));
    }
    await loader.load();
  }
  await (FontLoader(
    'MaterialIcons',
  )..addFont(_read(fonts, 'materialicons-regular.otf'))).load();
}

Future<ByteData> _read(Directory dir, String name) async {
  final bytes = await File('${dir.path}/$name').readAsBytes();
  return ByteData.sublistView(bytes);
}

/// `bin/cache/artifacts/material_fonts` of the SDK running the tests.
Directory _materialFontsDirectory() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (root != null) Directory('$root/bin/cache/artifacts/material_fonts'),
    // flutter_tester lives in bin/cache/artifacts/engine/<platform>/.
    Directory(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
      '/material_fonts',
    ),
  ];
  for (final dir in candidates) {
    if (dir.existsSync()) return dir;
  }
  throw StateError(
    'Material fonts not found in the Flutter SDK cache; run `flutter precache`.',
  );
}
