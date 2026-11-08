import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Deletes a point and hands it back, so that it can be restored. The
/// screen confirms first.
final class DeletePointBloc extends ActionBloc<SavedPoint, SavedPoint> {
  DeletePointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(SavedPoint params) async =>
      (await _points.delete(params.id)).map((_) => params);
}
