import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Deletes a point; the parameter is its id. The screen confirms first.
final class DeletePointBloc extends ActionBloc<String, void> {
  DeletePointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<void>> perform(String params) => _points.delete(params);
}
