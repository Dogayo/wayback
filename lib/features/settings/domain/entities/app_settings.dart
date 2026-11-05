import 'package:wayback/core/utils/geo/distance_formatter.dart';

export 'package:wayback/core/utils/geo/distance_formatter.dart' show UnitSystem;

/// Interface language; [system] follows the phone and falls back to English
/// for a language the app does not have.
enum AppLanguage { system, ru, en }

/// The user's preferences (mvp-scope.md §2).
final class AppSettings {
  const AppSettings({
    this.units = UnitSystem.metric,
    this.language = AppLanguage.system,
    this.vibrationOnArrival = true,
  });

  /// Before anything is saved.
  static const defaults = AppSettings();

  final UnitSystem units;
  final AppLanguage language;
  final bool vibrationOnArrival;

  AppSettings copyWith({
    UnitSystem? units,
    AppLanguage? language,
    bool? vibrationOnArrival,
  }) => AppSettings(
    units: units ?? this.units,
    language: language ?? this.language,
    vibrationOnArrival: vibrationOnArrival ?? this.vibrationOnArrival,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.units == units &&
      other.language == language &&
      other.vibrationOnArrival == vibrationOnArrival;

  @override
  int get hashCode => Object.hash(units, language, vibrationOnArrival);
}
