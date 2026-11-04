import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';

import '../fake_location_repository.dart';

void main() {
  test('signal is weak only above the threshold', () {
    expect(fixWithAccuracy(8).isWeakSignal, isFalse);
    expect(fixWithAccuracy(weakSignalAccuracyMeters).isWeakSignal, isFalse);
    expect(fixWithAccuracy(65).isWeakSignal, isTrue);
  });
}
