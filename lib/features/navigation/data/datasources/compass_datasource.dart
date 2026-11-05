import 'package:wayback/features/navigation/data/models/compass_reading_model.dart';

/// Reports a missing or failed compass as a `SensorException` with
/// `NavigationErrorCodes.compassUnavailable` in the stream.
abstract interface class CompassDatasource {
  Stream<CompassReadingModel> watchHeading();
}
