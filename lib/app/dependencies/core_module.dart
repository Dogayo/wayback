import 'dart:developer' as developer;

import 'package:app_di/app_di.dart';

import 'package:wayback/core/result/result_handler.dart';

/// App-wide infrastructure shared by feature modules.
final class CoreModule extends DependencyCollection {
  const CoreModule();

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<ResultHandlerOptions>(
      (_) => const ResultHandlerOptions(onError: _logError),
      isSingleton: true,
    ),
  ];
}

/// Every error a repository caught: the user sees a localized failure,
/// the code and cause stay in the log (architecture.md §4.2).
void _logError(Object error, StackTrace stackTrace) => developer.log(
  '$error',
  name: 'wayback.repository',
  error: error,
  stackTrace: stackTrace,
);
