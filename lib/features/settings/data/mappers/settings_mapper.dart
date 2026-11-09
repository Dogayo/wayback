import 'package:wayback/features/settings/data/models/settings_model.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';

/// A missing or unknown value falls back to [AppSettings.defaults].
extension SettingsModelMapper on SettingsModel {
  AppSettings toEntity() {
    const defaults = AppSettings.defaults;
    return AppSettings(
      units: UnitSystem.values.asNameMap()[units] ?? defaults.units,
      language: AppLanguage.values.asNameMap()[language] ?? defaults.language,
      vibrationOnArrival: vibrationOnArrival ?? defaults.vibrationOnArrival,
      vibrationPattern:
          VibrationPattern.values.asNameMap()[vibrationPattern] ??
          defaults.vibrationPattern,
      touchFeedback: touchFeedback ?? defaults.touchFeedback,
    );
  }
}

extension AppSettingsMapper on AppSettings {
  SettingsModel toModel() => SettingsModel(
    units: units.name,
    language: language.name,
    vibrationOnArrival: vibrationOnArrival,
    vibrationPattern: vibrationPattern.name,
    touchFeedback: touchFeedback,
  );
}
