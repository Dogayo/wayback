import 'dart:developer' as developer;

import 'package:app_di/app_di.dart';
import 'package:app_logger/app_logger.dart';

import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/result/result_handler.dart';

/// App-wide infrastructure shared by feature modules.
final class CoreModule extends DependencyCollection {
  const CoreModule(this._logger);

  /// Opened in bootstrap, so it also sees what fails before the container.
  final AppLogger _logger;

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<AppLogger>((_) => _logger, isSingleton: true),
    RegFactory<ResultHandlerOptions>(
      (_) => ResultHandlerOptions(onError: _logError),
      isSingleton: true,
    ),
  ];

  /// Every error a repository caught: the user sees a localized failure,
  /// the code and cause stay in the log (architecture.md §4.2). An
  /// [AppException] is an expected case such as a denied permission; anything
  /// else is a bug.
  void _logError(Object error, StackTrace stackTrace) {
    developer.log(
      '$error',
      name: 'wayback.repository',
      error: error,
      stackTrace: stackTrace,
    );
    _logger.log(
      error is AppException ? LogLevel.warning : LogLevel.error,
      'repository',
      error is AppException ? error.code : 'unexpected',
      error: error,
      stackTrace: error is AppException ? null : stackTrace,
    );
  }
}
