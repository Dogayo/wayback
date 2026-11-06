import 'package:app_logger/app_logger.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';

/// What the navigation screen saw, for reading after a walk
/// (mvp-scope.md §2.7): a sample at most every [interval] and every change
/// of arrival, signal or compass state at once. The point's name stays out;
/// coordinates are private and never leave the device.
final class NavigationTelemetry {
  NavigationTelemetry(
    this._logger, {
    required this.pointId,
    this.interval = const Duration(seconds: 1),
  });

  static const _tag = 'navigation';

  final AppLogger _logger;
  final String pointId;
  final Duration interval;
  final _sinceSample = Stopwatch();

  bool? _arrived;
  bool? _weakSignal;
  CompassStatus? _compass;

  void started() => _logger.info(_tag, 'started', fields: {'point': pointId});

  void stopped() => _logger.info(_tag, 'stopped', fields: {'point': pointId});

  void failed(String code) =>
      _logger.warning(_tag, 'failed', fields: {'code': code});

  void guided({
    required LocationFix fix,
    required NavigationGuidance guidance,
    required double bearingDegrees,
    required CompassReading? reading,
  }) {
    _changed('arrived', _arrived, guidance.arrived);
    _changed('weak_signal', _weakSignal, guidance.weakSignal);
    _changed('compass', _compass?.name, guidance.compass.name);
    _arrived = guidance.arrived;
    _weakSignal = guidance.weakSignal;
    _compass = guidance.compass;

    if (_sinceSample.isRunning && _sinceSample.elapsed < interval) return;
    _sinceSample
      ..reset()
      ..start();
    _logger.debug(
      _tag,
      'sample',
      fields: {
        'distance': _rounded(guidance.distanceMeters),
        'accuracy': _rounded(guidance.accuracyMeters),
        'bearing': _rounded(bearingDegrees),
        'heading': _rounded(reading?.headingDegrees),
        'compassAccuracy': _rounded(reading?.accuracyDegrees),
        'arrow': _rounded(guidance.arrowDegrees),
        'fixAgeMs': DateTime.now().difference(fix.timestamp).inMilliseconds,
      },
      private: {
        'lat': fix.point.latitude,
        'lon': fix.point.longitude,
        'alt': fix.altitudeMeters,
      },
    );
  }

  void _changed(String name, Object? from, Object to) {
    if (from == to) return;
    _logger.info(_tag, name, fields: {'from': from, 'to': to});
  }

  static double? _rounded(double? value) =>
      value == null ? null : double.parse(value.toStringAsFixed(1));
}
