import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Vibrates on arrival. A failure shows nothing: "Вы на месте" is on the
/// screen anyway, and the log keeps the state change.
final class ArrivalVibrationBloc extends ActionBloc<VibrationPattern, void> {
  ArrivalVibrationBloc(this._vibration);

  final VibrationRepository _vibration;

  @override
  Future<Result<void>> perform(VibrationPattern params) =>
      _vibration.vibrate(params);
}
