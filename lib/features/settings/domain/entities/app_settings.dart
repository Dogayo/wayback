import 'package:wayback/core/utils/geo/distance_formatter.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';

export 'package:wayback/core/utils/geo/distance_formatter.dart' show UnitSystem;
export 'package:wayback/core/utils/vibration/vibration_pattern.dart';

/// Interface language; [system] follows the phone and falls back to English
/// for a language the app does not have.
enum AppLanguage { system, ru, en }

/// The user's preferences (mvp-scope.md §2).
final class AppSettings {
  const AppSettings({
    this.units = UnitSystem.metric,
    this.language = AppLanguage.system,
    this.vibrationOnArrival = true,
    this.vibrationPattern = VibrationPattern.standard,
  });

  /// Before anything is saved.
  static const defaults = AppSettings();

  final UnitSystem units;
  final AppLanguage language;
  final bool vibrationOnArrival;
  final VibrationPattern vibrationPattern;

  AppSettings copyWith({
    UnitSystem? units,
    AppLanguage? language,
    bool? vibrationOnArrival,
    VibrationPattern? vibrationPattern,
  }) => AppSettings(
    units: units ?? this.units,
    language: language ?? this.language,
    vibrationOnArrival: vibrationOnArrival ?? this.vibrationOnArrival,
    vibrationPattern: vibrationPattern ?? this.vibrationPattern,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.units == units &&
      other.language == language &&
      other.vibrationOnArrival == vibrationOnArrival &&
      other.vibrationPattern == vibrationPattern;

  @override
  int get hashCode =>
      Object.hash(units, language, vibrationOnArrival, vibrationPattern);
}
