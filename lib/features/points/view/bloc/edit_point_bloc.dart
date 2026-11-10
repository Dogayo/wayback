import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

typedef PointEdit = ({String id, String name, PointType type});

/// Changes the name and type of a saved point.
final class EditPointBloc extends ActionBloc<PointEdit, SavedPoint> {
  EditPointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(PointEdit params) =>
      _points.edit(params.id, name: params.name, type: params.type);
}
