import 'dart:io';

/// One Dart file of `lib/`, path relative to the package root.
typedef SourceFile = ({String path, String content});

/// A broken rule in one file.
final class Violation {
  const Violation(this.rule, this.path, this.message);

  final String rule;
  final String path;
  final String message;

  @override
  String toString() => '[$rule] $path: $message';
}

/// Every hand-written Dart file under `lib/`.
List<SourceFile> readLibrary() => [
  for (final entity in Directory('lib').listSync(recursive: true))
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.contains('/generated/'))
      (
        path: entity.path.replaceAll(r'\', '/'),
        content: entity.readAsStringSync(),
      ),
];

/// Source without comments, so that docs mentioning a rule do not break it.
String stripComments(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp('//.*'), '');

String basename(String path) => path.split('/').last;
