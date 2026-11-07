import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';

extension SettingsL10n on AppLocalizations {
  String unitSystem(UnitSystem units) => switch (units) {
    UnitSystem.metric => settingsUnitsMetric,
    UnitSystem.imperial => settingsUnitsImperial,
  };

  /// Language names are their own names, the same in every locale.
  String appLanguage(AppLanguage language) => switch (language) {
    AppLanguage.system => settingsLanguageSystem,
    AppLanguage.ru => settingsLanguageRu,
    AppLanguage.en => settingsLanguageEn,
  };

  String vibrationPattern(VibrationPattern pattern) => switch (pattern) {
    VibrationPattern.standard => settingsVibrationStandard,
    VibrationPattern.long => settingsVibrationLong,
    VibrationPattern.twice => settingsVibrationTwice,
    VibrationPattern.strong => settingsVibrationStrong,
  };
}
