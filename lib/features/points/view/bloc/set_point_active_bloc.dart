import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Switches whether a point is active, i.e. shown on Home.
final class SetPointActiveBloc
    extends ActionBloc<({String id, bool active}), SavedPoint> {
  SetPointActiveBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(({String id, bool active}) params) =>
      _points.setActive(params.id, active: params.active);
}
