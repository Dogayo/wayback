import 'package:flutter_compass/flutter_compass.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/navigation/data/datasources/compass_datasource.dart';
import 'package:wayback/features/navigation/data/models/compass_reading_model.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';

final class FlutterCompassDatasource implements CompassDatasource {
  const FlutterCompassDatasource();

  @override
  Stream<CompassReadingModel> watchHeading() {
    final events = FlutterCompass.events;
    if (events == null) {
      return Stream.error(
        const SensorException(
          code: NavigationErrorCodes.compassUnavailable,
          description: 'The platform offers no compass stream',
        ),
      );
    }
    return events.map(
      (event) => switch (event.heading) {
        final heading? => CompassReadingModel(
          heading: heading,
          accuracy: event.accuracy,
        ),
        // The plugin sends events without a heading on devices without the
        // sensors it needs.
        null => throw const SensorException(
          code: NavigationErrorCodes.compassUnavailable,
          description: 'Compass event without a heading',
        ),
      },
    );
  }
}
