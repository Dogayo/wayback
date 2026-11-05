import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/points_with_distance.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';
export 'package:wayback/features/points/view/bloc/points_with_distance.dart'
    show PointDistance;

/// One point with its distance, kept current (SCREENS.md §4.4). A point
/// that is gone — deleted, or a deep link to nothing — is `points_not_found`.
final class PointDetailsBloc extends DataBloc<PointDistance> {
  PointDetailsBloc(this._points, this._location, {required this.pointId});

  final PointsRepository _points;
  final LocationRepository _location;
  final String pointId;

  @override
  Stream<Result<PointDistance>> watch() =>
      watchPointsWithDistance(_points, _location).map(
        (result) => switch (result) {
          Success(:final value) => _find(value),
          Failed(:final failure) => Result.failure(failure),
        },
      );

  Result<PointDistance> _find(List<PointDistance> all) {
    for (final item in all) {
      if (item.point.id == pointId) return Result.success(item);
    }
    return const Result.failure(
      NotFoundFailure(code: PointsErrorCodes.notFound),
    );
  }
}
