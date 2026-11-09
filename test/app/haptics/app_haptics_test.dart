import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/haptics/app_haptics.dart';
import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../features/navigation/fake_vibration_repository.dart';

void main() {
  late FakeVibrationRepository vibration;
  late DateTime clock;
  late AppHaptics haptics;

  setUp(() {
    vibration = FakeVibrationRepository();
    clock = DateTime.utc(2026, 11, 9);
    haptics = AppHaptics(vibration, now: () => clock);
  });

  test('each level reaches the vibrator', () {
    for (final haptic in WbHaptic.values) {
      haptics.play(haptic);
      clock = clock.add(AppHaptics.minGap);
    }

    expect(vibration.pulses, HapticLevel.values);
  });

  test('turned off, nothing vibrates', () {
    haptics
      ..enabled = false
      ..play(WbHaptic.warning);

    expect(vibration.pulses, isEmpty);
  });

  test('pulses too close together do not stack', () {
    haptics.play(WbHaptic.tick);
    clock = clock.add(const Duration(milliseconds: 30));
    haptics.play(WbHaptic.tick);
    expect(vibration.pulses, hasLength(1));

    clock = clock.add(AppHaptics.minGap);
    haptics.play(WbHaptic.tick);
    expect(vibration.pulses, hasLength(2));
  });
}
