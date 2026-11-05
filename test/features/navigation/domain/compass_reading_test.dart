import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/navigation/data/mappers/compass_reading_mapper.dart';
import 'package:wayback/features/navigation/data/models/compass_reading_model.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';

void main() {
  test('unreliable above the threshold or when unknown', () {
    expect(
      const CompassReading(headingDegrees: 0, accuracyDegrees: 15).isUnreliable,
      isFalse,
    );
    expect(
      const CompassReading(headingDegrees: 0, accuracyDegrees: 30).isUnreliable,
      isFalse,
    );
    expect(
      const CompassReading(headingDegrees: 0, accuracyDegrees: 45).isUnreliable,
      isTrue,
    );
    expect(const CompassReading(headingDegrees: 0).isUnreliable, isTrue);
  });

  test('negative headings map into 0..360', () {
    expect(
      const CompassReadingModel(
        heading: -90,
        accuracy: 15,
      ).toEntity().headingDegrees,
      270,
    );
  });
}
