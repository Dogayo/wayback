import 'package:app_di/app_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wayback/app/dependencies/core_module.dart';
import 'package:wayback/app/dependencies/location_module.dart';
import 'package:wayback/app/dependencies/navigation_module.dart';
import 'package:wayback/app/dependencies/onboarding_module.dart';
import 'package:wayback/app/dependencies/points_module.dart';
import 'package:wayback/app/dependencies/settings_module.dart';

/// Every feature module of the app, registered as one collection.
final class AppDependencies extends DependencyCollection {
  const AppDependencies({required this.preferences});

  final SharedPreferences preferences;

  @override
  Iterable<RegType> get dependencies => [
    ...const CoreModule().dependencies,
    ...const LocationModule().dependencies,
    ...PointsModule(preferences).dependencies,
    ...const NavigationModule().dependencies,
    ...SettingsModule(preferences).dependencies,
    ...OnboardingModule(preferences).dependencies,
  ];
}
