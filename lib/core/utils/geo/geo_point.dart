/// A position on Earth in decimal degrees (WGS 84).
final class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude})
    : assert(
        latitude >= -90 && latitude <= 90,
        'latitude must be within -90..90',
      ),
      assert(
        longitude >= -180 && longitude <= 180,
        'longitude must be within -180..180',
      );

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
