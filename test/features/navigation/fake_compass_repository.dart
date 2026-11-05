import 'dart:async';

import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';

CompassReading heading(double degrees, {double? accuracy = 15}) =>
    CompassReading(headingDegrees: degrees, accuracyDegrees: accuracy);

final class FakeCompassRepository implements CompassRepository {
  final readings = StreamController<Result<CompassReading>>.broadcast();

  bool get isListened => readings.hasListener;

  @override
  Stream<Result<CompassReading>> watchHeading() => readings.stream;
}
