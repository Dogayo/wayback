import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/points_with_distance.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';
export 'package:wayback/features/points/view/bloc/points_with_distance.dart'
    show PointDistance;

/// Every saved point with its distance (SCREENS.md §4.3). Points are local
/// and few, so the whole list comes at once — no pages.
final class PointsListBloc extends DataBloc<List<PointDistance>> {
  PointsListBloc(this._points, this._location);

  final PointsRepository _points;
  final LocationRepository _location;

  @override
  Stream<Result<List<PointDistance>>> watch() =>
      watchPointsWithDistance(_points, _location);
}
