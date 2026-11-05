import 'package:flutter_test/flutter_test.dart';

import 'screen_rules.dart';
import 'source_file.dart';

/// Quality gate for screens and widgets: every rule from screen_rules.dart
/// over `lib/`. Rules and their reasons are in docs/architecture.md §3.5.
void main() {
  test('screens and widgets in lib/ follow the screen rules', () {
    final violations = checkScreenRules(readLibrary());

    expect(violations, isEmpty, reason: '\n${violations.join('\n')}\n');
  });
}
