import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

typedef NewPoint = ({
  String name,
  PointType type,
  GeoPoint position,
  double? altitudeMeters,
});

/// Saves a new point; it is active right away.
final class SavePointBloc extends ActionBloc<NewPoint, SavedPoint> {
  SavePointBloc(this._points);

  final PointsRepository _points;

  @override
  Future<Result<SavedPoint>> perform(NewPoint params) => _points.create(
    name: params.name,
    type: params.type,
    position: params.position,
    altitudeMeters: params.altitudeMeters,
  );
}
