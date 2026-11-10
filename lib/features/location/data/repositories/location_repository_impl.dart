import 'dart:async';

import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/mappers/location_fix_mapper.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

final class LocationRepositoryImpl
    with ResultHandler
    implements LocationRepository {
  LocationRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final LocationDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<LocationAccess>> checkAccess() =>
      handle(_datasource.checkAccess);

  @override
  Future<Result<LocationAccess>> requestAccess() =>
      handle(_datasource.requestAccess);

  @override
  Future<Result<LocationAccess>> requestPreciseAccess() => handle(() async {
    final access = await _datasource.requestAccess();
    if (access == LocationAccess.approximate) {
      await _datasource.openAppSettings();
    }
    return access;
  });

  @override
  Future<Result<LocationFix>> currentFix() => handle(() async {
    await _requirePrecise();
    return (await _datasource.currentFix()).toEntity();
  });

  /// A point saved or a way shown from an approximate position would be off
  /// by kilometers, and could even announce arrival: positions snap to a
  /// coarse grid.
  Future<void> _requirePrecise() async {
    if (await _datasource.checkAccess() == LocationAccess.approximate) {
      throw const PermissionException(code: LocationErrorCodes.preciseRequired);
    }
  }

  Stream<LocationFix> _fixes() async* {
    await _requirePrecise();
    yield* _datasource.watchFix().map((model) => model.toEntity());
  }

  /// One GPS subscription shared by every screen that watches fixes. It
  /// starts with the first listener, stops after the last one, and starts
  /// again when the plugin stream ends — it does after a permission error,
  /// and a listener that comes after the user allowed access must get fixes,
  /// not that old error.
  late final _shared = StreamController<Result<LocationFix>>.broadcast(
    onListen: _startUpstream,
    onCancel: () {
      unawaited(_upstream?.cancel());
      _upstream = null;
      _lastFix = null;
    },
  );
  StreamSubscription<Result<LocationFix>>? _upstream;

  /// Only a fix is replayed to a new listener; a failure may be outdated by
  /// the time someone else listens.
  Result<LocationFix>? _lastFix;

  /// A new listener gets the latest fix right away, then every next result.
  @override
  Stream<Result<LocationFix>> watchFix() => Stream.multi((listener) {
    final subscription = _shared.stream.listen(
      listener.add,
      onDone: listener.close,
    );
    if (_upstream == null && _shared.hasListener) _startUpstream();
    if (_lastFix case final last?) listener.add(last);
    listener.onCancel = subscription.cancel;
  });

  static bool _needsAccess(Failure failure) =>
      failure is PermissionFailure ||
      failure.code == LocationErrorCodes.serviceDisabled;

  void _startUpstream() {
    final stream = handleStream(_fixes());
    _upstream = stream.listen(
      (result) {
        if (result.isSuccess) _lastFix = result;
        _shared.add(result);
        // Without access the plugin stream is dead even if it stays open;
        // drop it, so the next listener (after the user fixed access)
        // starts a fresh one. A lost signal keeps the stream running.
        if (result.failureOrNull case final failure?
            when _needsAccess(failure)) {
          unawaited(_upstream?.cancel());
          _upstream = null;
        }
      },
      onDone: () {
        _upstream = null;
        _lastFix = null;
      },
    );
  }

  @override
  Future<Result<void>> openAppSettings() => handle(_datasource.openAppSettings);

  @override
  Future<Result<void>> openLocationSettings() =>
      handle(_datasource.openLocationSettings);
}
