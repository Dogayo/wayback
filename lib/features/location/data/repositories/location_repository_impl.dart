import 'dart:async';

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
  Future<Result<LocationFix>> currentFix() =>
      handle(() async => (await _datasource.currentFix()).toEntity());

  /// One GPS subscription shared by every screen that watches fixes; it
  /// starts with the first listener and stops after the last one.
  late final _shared = StreamController<Result<LocationFix>>.broadcast(
    onListen: () => _upstream = handleStream(
      _datasource.watchFix().map((model) => model.toEntity()),
    ).listen(_onFix),
    onCancel: () {
      unawaited(_upstream?.cancel());
      _upstream = null;
      _last = null;
    },
  );
  StreamSubscription<Result<LocationFix>>? _upstream;
  Result<LocationFix>? _last;

  /// A new listener gets the latest result right away, then every next one.
  @override
  Stream<Result<LocationFix>> watchFix() => Stream.multi((listener) {
    final subscription = _shared.stream.listen(
      listener.add,
      onDone: listener.close,
    );
    if (_last case final last?) listener.add(last);
    listener.onCancel = subscription.cancel;
  });

  void _onFix(Result<LocationFix> result) {
    _last = result;
    _shared.add(result);
  }

  @override
  Future<Result<void>> openAppSettings() => handle(_datasource.openAppSettings);

  @override
  Future<Result<void>> openLocationSettings() =>
      handle(_datasource.openLocationSettings);
}
