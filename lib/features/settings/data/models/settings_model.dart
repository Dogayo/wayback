/// Stored form of the settings; the JSON layout is versioned by the storage
/// key. Enums are kept by name, so an unknown future value does not break
/// reading.
final class SettingsModel {
  const SettingsModel({this.units, this.language, this.vibrationOnArrival});

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    units: json['units'] as String?,
    language: json['language'] as String?,
    vibrationOnArrival: json['vibrationOnArrival'] as bool?,
  );

  final String? units;
  final String? language;
  final bool? vibrationOnArrival;

  Map<String, dynamic> toJson() => {
    if (units != null) 'units': units,
    if (language != null) 'language': language,
    if (vibrationOnArrival != null) 'vibrationOnArrival': vibrationOnArrival,
  };
}
