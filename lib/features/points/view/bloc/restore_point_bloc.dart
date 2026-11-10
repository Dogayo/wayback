import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Takes back a delete or a deactivation from the undo snackbar. It sits
/// above every route: the screen that did it may be gone by then.
final class RestorePointBloc extends ActionBloc<SavedPoint, SavedPoint> {
  RestorePointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(SavedPoint params) =>
      _points.restore(params);
}
