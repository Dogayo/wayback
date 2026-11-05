import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/point_type_l10n.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Map<String, String> _messages(String locale) {
  final arb =
      jsonDecode(
            File('lib/app/localization/arb/app_$locale.arb').readAsStringSync(),
          )
          as Map<String, dynamic>;
  return {
    for (final MapEntry(:key, :value) in arb.entries)
      if (!key.startsWith('@')) key: value as String,
  };
}

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m[1]!).toSet();

void main() {
  final ru = _messages('ru');
  final en = _messages('en');

  test('ru and en define the same keys', () {
    expect(en.keys.toSet(), ru.keys.toSet());
  });

  test('every message is non-empty and has the same placeholders', () {
    for (final key in ru.keys) {
      expect(ru[key], isNotEmpty, reason: 'ru $key');
      expect(en[key], isNotEmpty, reason: 'en $key');
      expect(
        _placeholders(en[key]!),
        _placeholders(ru[key]!),
        reason: 'placeholders of $key',
      );
    }
  });

  test('error codes match docs/copy.md §11.2', () {
    final section = File(
      'docs/copy.md',
    ).readAsStringSync().split('### 11.2').last.split('\n---').first;
    final documented = RegExp(
      r'^\| `(\w+)` \|',
      multiLine: true,
    ).allMatches(section).map((m) => m[1]!).toSet()..remove('generic');

    expect(localizedErrorCodes, documented);
  });

  for (final locale in ['ru', 'en']) {
    group(locale, () {
      late AppLocalizations l10n;
      setUpAll(() async {
        l10n = await AppLocalizations.delegate.load(Locale(locale));
      });

      test('every localized error code has its own title and body', () {
        final generic = l10n.error('unknown');
        for (final code in localizedErrorCodes) {
          final text = l10n.error(code);
          expect(text.title, isNot(generic.title), reason: code);
          expect(text.body, isNotEmpty, reason: code);
        }
      });

      test('an unknown code falls back to the generic text', () {
        expect(l10n.error('no_such_code'), (
          title: l10n.error_generic,
          body: l10n.error_generic_body,
        ));
      });

      test('every point type has a label', () {
        final labels = WbPointType.values.map(l10n.pointType).toSet();
        expect(labels, hasLength(WbPointType.values.length));
      });
    });
  }

  test('ru point type labels match the design system defaults', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    for (final type in WbPointType.values) {
      expect(l10n.pointType(type), type.label, reason: type.name);
    }
  });
}
