import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/data/datasources/compass_datasource.dart';
import 'package:wayback/features/navigation/data/models/compass_reading_model.dart';
import 'package:wayback/features/navigation/data/repositories/compass_repository_impl.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';

final class _Datasource implements CompassDatasource {
  final events = StreamController<CompassReadingModel>();

  @override
  Stream<CompassReadingModel> watchHeading() => events.stream;
}

void main() {
  test('readings become results; a lost sensor is a failure', () async {
    final datasource = _Datasource();
    final results = <Result<CompassReading>>[];
    final sub = CompassRepositoryImpl(
      datasource,
    ).watchHeading().listen(results.add);

    datasource.events
      ..add(const CompassReadingModel(heading: 10, accuracy: 15))
      ..addError(
        const SensorException(code: NavigationErrorCodes.compassUnavailable),
      );
    await pumpEventQueue();
    await sub.cancel();

    expect(
      results.first,
      const Success(CompassReading(headingDegrees: 10, accuracyDegrees: 15)),
    );
    expect(
      results.last.failureOrNull,
      const SensorFailure(code: NavigationErrorCodes.compassUnavailable),
    );
  });
}
