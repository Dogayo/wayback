import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Renames a point.
final class RenamePointBloc
    extends ActionBloc<({String id, String name}), SavedPoint> {
  RenamePointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(({String id, String name}) params) =>
      _points.rename(params.id, params.name);
}
