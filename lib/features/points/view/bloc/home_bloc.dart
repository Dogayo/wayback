import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/points_with_distance.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';
export 'package:wayback/features/points/view/bloc/points_with_distance.dart'
    show PointDistance;

/// What Home shows: the active points and how many points exist at all,
/// which tells "nothing saved" from "nothing active".
final class HomePoints {
  const HomePoints({required this.active, required this.total});

  final List<PointDistance> active;
  final int total;

  bool get hasNoPoints => total == 0;

  bool get hasNoActive => total > 0 && active.isEmpty;
}

/// Active points with distances for Home (SCREENS.md §4.1).
final class HomeBloc extends DataBloc<HomePoints> {
  HomeBloc(this._points, this._location);

  final PointsRepository _points;
  final LocationRepository _location;

  @override
  Stream<Result<HomePoints>> watch() =>
      watchPointsWithDistance(_points, _location).map(
        (result) => result.map(
          (all) => HomePoints(
            active: [
              for (final item in all)
                if (item.point.isActive) item,
            ],
            total: all.length,
          ),
        ),
      );
}
