import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';

/// Failure codes [CompassRepository] can return (architecture.md §4.2).
abstract final class NavigationErrorCodes {
  static const compassUnavailable = 'navigation_compass_unavailable';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class CompassRepository {
  /// Readings while listened to; the sensor stops when the last listener
  /// cancels.
  Stream<Result<CompassReading>> watchHeading();
}
