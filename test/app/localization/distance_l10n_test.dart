import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';

void main() {
  test('ru labels', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    expect(l10n.distance(850), '850\u00A0м');
    expect(l10n.distance(1234), '1,2\u00A0км');
  });

  test('en labels', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.distance(850), '850\u00A0m');
    expect(l10n.distance(1234), '1.2\u00A0km');
  });
}
