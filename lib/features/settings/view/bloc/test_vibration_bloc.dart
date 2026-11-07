import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Plays a vibration so the user can feel it before relying on it.
final class TestVibrationBloc extends ActionBloc<VibrationPattern, void> {
  TestVibrationBloc(this._vibration);

  final VibrationRepository _vibration;

  @override
  Future<Result<void>> perform(VibrationPattern params) =>
      _vibration.vibrate(params);
}
