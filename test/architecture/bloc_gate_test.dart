import 'package:flutter_test/flutter_test.dart';

import 'bloc_rules.dart';
import 'source_file.dart';

/// Quality gate for blocs: every rule from bloc_rules.dart over `lib/`.
/// Rules and their reasons are in docs/architecture.md §3.4.
void main() {
  test('blocs in lib/ follow the bloc rules', () {
    final violations = checkBlocRules(readLibrary());

    expect(violations, isEmpty, reason: '\n${violations.join('\n')}\n');
  });
}
