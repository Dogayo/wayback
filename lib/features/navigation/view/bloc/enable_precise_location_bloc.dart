import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Asks for precise location from the navigation error. Navigation uses the
/// location domain only, so this does not reuse the location feature's view.
final class EnablePreciseLocationBloc extends ActionBloc<void, LocationAccess> {
  EnablePreciseLocationBloc(this._location);

  final LocationRepository _location;

  @override
  Future<Result<LocationAccess>> perform(void params) =>
      _location.requestPreciseAccess();
}
