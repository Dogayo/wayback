import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the on-device log (mvp-scope.md §2.7). On Android it lives in the
/// app's external files directory, the only place `adb` can read in a release
/// build. Without a usable directory the app simply runs without a log.
Future<AppLogger> openAppLog() async {
  try {
    final external = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : null;
    final root = external ?? await getApplicationSupportDirectory();
    final logger = FileLogger(directory: Directory('${root.path}/logs'));
    unawaited(logger.prune());
    final package = await PackageInfo.fromPlatform();
    logger.info(
      'app',
      'started',
      fields: {
        'version': package.version,
        'build': package.buildNumber,
        'os': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
      },
    );
    return logger;
  } on Object {
    return const NoopLogger();
  }
}

/// Sends Flutter and uncaught Dart errors to the log, keeping their default
/// handling. Native crashes are out of reach here.
void logCrashes(AppLogger logger) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'flutter',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error('dart', 'uncaught', error: error, stackTrace: stackTrace);
    return false;
  };
}
