import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';

/// One fresh fix for a new point; fetch again to retry.
final class PointFixBloc extends DataBloc<LocationFix> {
  PointFixBloc(this._location);

  final LocationRepository _location;

  @override
  Stream<Result<LocationFix>> watch() => _location.currentFix().asStream();
}
