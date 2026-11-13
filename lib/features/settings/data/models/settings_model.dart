/// Stored form of the settings; the JSON layout is versioned by the storage
/// key. Enums are kept by name, so an unknown future value does not break
/// reading.
final class SettingsModel {
  const SettingsModel({
    this.units,
    this.language,
    this.themeMode,
    this.vibrationOnArrival,
    this.vibrationPattern,
    this.touchFeedback,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    units: json['units'] as String?,
    language: json['language'] as String?,
    themeMode: json['themeMode'] as String?,
    vibrationOnArrival: json['vibrationOnArrival'] as bool?,
    vibrationPattern: json['vibrationPattern'] as String?,
    touchFeedback: json['touchFeedback'] as bool?,
  );

  final String? units;
  final String? language;
  final String? themeMode;
  final bool? vibrationOnArrival;
  final String? vibrationPattern;
  final bool? touchFeedback;

  Map<String, dynamic> toJson() => {
    if (units != null) 'units': units,
    if (language != null) 'language': language,
    if (themeMode != null) 'themeMode': themeMode,
    if (vibrationOnArrival != null) 'vibrationOnArrival': vibrationOnArrival,
    if (vibrationPattern != null) 'vibrationPattern': vibrationPattern,
    if (touchFeedback != null) 'touchFeedback': touchFeedback,
  };
}
