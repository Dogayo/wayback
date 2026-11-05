/// A compass event as the plugin reports it.
final class CompassReadingModel {
  const CompassReadingModel({required this.heading, this.accuracy});

  final double heading;
  final double? accuracy;
}
