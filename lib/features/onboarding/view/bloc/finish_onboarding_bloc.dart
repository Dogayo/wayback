import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Ends onboarding after the system location dialog; whatever the answer,
/// Home handles missing access (SCREENS.md §3).
final class FinishOnboardingBloc extends ActionBloc<void, void> {
  FinishOnboardingBloc(this._onboarding, this._location);

  final OnboardingRepository _onboarding;
  final LocationRepository _location;

  @override
  Future<Result<void>> perform(void params) async {
    await _location.requestAccess();
    return _onboarding.complete();
  }
}
