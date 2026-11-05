import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/features/navigation/data/models/compass_reading_model.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';

extension CompassReadingMapper on CompassReadingModel {
  /// Headings come as `-180..180` on some devices; the domain uses `0..360`.
  CompassReading toEntity() => CompassReading(
    headingDegrees: normalizeDegrees(heading),
    accuracyDegrees: accuracy,
  );
}
