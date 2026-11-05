import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/onboarding/view/bloc/finish_onboarding_bloc.dart';

import '../../location/fake_location_repository.dart';
import '../fake_onboarding_repository.dart';

void main() {
  test('Allow asks for location, then completes', () async {
    final onboarding = FakeOnboardingRepository(completed: false);
    final location = FakeLocationRepository();
    final bloc = FinishOnboardingBloc(onboarding, location);
    addTearDown(bloc.close);

    bloc.run(true);
    await pumpEventQueue();

    expect(location.requests, 1);
    expect(onboarding.completed, isTrue);
    expect(bloc.state.mapOrNull(success: (_) => true), isTrue);
  });

  test('Not now completes without asking', () async {
    final onboarding = FakeOnboardingRepository(completed: false);
    final location = FakeLocationRepository();
    final bloc = FinishOnboardingBloc(onboarding, location);
    addTearDown(bloc.close);

    bloc.run(false);
    await pumpEventQueue();

    expect(location.requests, 0);
    expect(onboarding.completed, isTrue);
  });
}
