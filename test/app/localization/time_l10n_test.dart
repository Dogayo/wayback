import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/time_l10n.dart';

void main() {
  final now = DateTime(2026, 11, 5, 14, 30);

  setUpAll(() async {
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en');
  });

  test('ru relative save times', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    String when(DateTime at) => l10n.savedWhen(at, now: now);

    expect(when(now.subtract(const Duration(seconds: 20))), 'только что');
    expect(when(now.subtract(const Duration(minutes: 12))), '12 мин назад');
    expect(when(DateTime(2026, 11, 5, 9)), '5 ч назад');
    expect(when(DateTime(2026, 11, 4, 23)), 'вчера');
    expect(when(DateTime(2026, 11, 2, 9)), '2 нояб.');
    expect(when(DateTime(2025, 11, 2, 9)), contains('2025'));
  });

  test('en uses month-first dates', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(l10n.savedWhen(DateTime(2026, 11, 2), now: now), 'Nov 2');
    expect(l10n.savedWhen(DateTime(2026, 11, 4, 10), now: now), 'yesterday');
  });
}
