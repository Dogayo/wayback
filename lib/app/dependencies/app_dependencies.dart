import 'package:app_di/app_di.dart';

import 'package:wayback/app/dependencies/location_module.dart';
import 'package:wayback/app/dependencies/navigation_module.dart';
import 'package:wayback/app/dependencies/points_module.dart';
import 'package:wayback/app/dependencies/settings_module.dart';

/// Every feature module of the app, registered as one collection.
final class AppDependencies extends DependencyCollection {
  const AppDependencies();

  @override
  Iterable<RegType> get dependencies => [
    ...const LocationModule().dependencies,
    ...const PointsModule().dependencies,
    ...const NavigationModule().dependencies,
    ...const SettingsModule().dependencies,
  ];
}
