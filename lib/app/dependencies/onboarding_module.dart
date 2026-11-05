import 'package:app_di/app_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:wayback/features/onboarding/data/datasources/shared_preferences_onboarding_datasource.dart';
import 'package:wayback/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

final class OnboardingModule extends DependencyCollection {
  const OnboardingModule(this._preferences);

  /// Initialized in bootstrap before the container is built.
  final SharedPreferences _preferences;

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<OnboardingLocalDatasource>(
      (_) => SharedPreferencesOnboardingDatasource(_preferences),
      isSingleton: true,
    ),
    // Singleton: the router and the onboarding screen share its cache.
    RegFactory<OnboardingRepository>(
      (i) => OnboardingRepositoryImpl(
        i.get<OnboardingLocalDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
  ];
}
