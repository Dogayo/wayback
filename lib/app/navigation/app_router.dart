import 'package:app_di/app_di.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/point_type_l10n.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:wayback/features/onboarding/view/bloc/finish_onboarding_bloc.dart';
import 'package:wayback/features/onboarding/view/screens/onboarding_screen.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/open_fix_settings_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_fix_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';

/// Every screen is a child of `/`, so a deep link to `/points/:id` keeps
/// Home under it and "back" leads to `/` (SCREENS.md §3).
///
/// Blocs are created here, in `BlocProvider`s; only their repositories come
/// from DI (architecture.md §5).
GoRouter createRouter({String initialLocation = Routes.home}) => GoRouter(
  initialLocation: initialLocation,
  redirect: _onboardingFirst,
  routes: [
    GoRoute(
      path: Routes.onboarding,
      builder: (_, _) => BlocProvider(
        create: (context) => FinishOnboardingBloc(
          context.di<OnboardingRepository>(),
          context.di<LocationRepository>(),
        ),
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: Routes.home,
      builder: (_, _) => MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) =>
                LocationFixBloc(context.di<LocationRepository>())..fetch(),
          ),
          BlocProvider(
            create: (context) =>
                RequestLocationPermissionBloc(context.di<LocationRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                OpenLocationSettingsBloc(context.di<LocationRepository>()),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => HomeBloc(
              context.di<PointsRepository>(),
              context.di<LocationRepository>(),
            )..fetch(),
          ),
        ],
        child: const HomeScreen(gpsStatus: GpsStatus()),
      ),
      routes: [
        GoRoute(
          path: 'points/new',
          builder: (context, _) {
            // Read here: a provider's create must not subscribe to inherited
            // widgets such as Localizations.
            final l10n = context.l10n;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => PointFormBloc(
                    context.di<PointsRepository>(),
                    labelOf: (type) => l10n.pointType(type.design),
                    numbered: l10n.pointDefaultNameNumbered,
                  )..add(const PointFormStarted()),
                ),
                BlocProvider(
                  create: (context) =>
                      PointFixBloc(context.di<LocationRepository>())..fetch(),
                ),
                BlocProvider(
                  create: (context) =>
                      SavePointBloc(context.di<PointsRepository>()),
                ),
                BlocProvider(
                  create: (context) =>
                      OpenFixSettingsBloc(context.di<LocationRepository>()),
                ),
              ],
              child: const PointCreateScreen(),
            );
          },
        ),
        GoRoute(
          path: 'points',
          builder: (_, _) => BlocProvider(
            create: (context) => PointsListBloc(
              context.di<PointsRepository>(),
              context.di<LocationRepository>(),
            )..fetch(),
            child: const PointsListScreen(),
          ),
        ),
        GoRoute(
          path: 'points/:${Routes.pointIdParam}',
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => PointDetailsBloc(
                  context.di<PointsRepository>(),
                  context.di<LocationRepository>(),
                  pointId: state.pathParameters[Routes.pointIdParam]!,
                )..fetch(),
              ),
              BlocProvider(
                create: (context) =>
                    RenamePointBloc(context.di<PointsRepository>()),
              ),
              BlocProvider(
                create: (context) =>
                    SetPointActiveBloc(context.di<PointsRepository>()),
              ),
              BlocProvider(
                create: (context) =>
                    DeletePointBloc(context.di<PointsRepository>()),
              ),
            ],
            child: const PointDetailsScreen(),
          ),
        ),
        GoRoute(
          path: 'navigate/:${Routes.pointIdParam}',
          builder: (_, state) => BlocProvider(
            create: (context) => NavigationGuidanceBloc(
              context.di<PointsRepository>(),
              context.di<LocationRepository>(),
              context.di<CompassRepository>(),
              pointId: state.pathParameters[Routes.pointIdParam]!,
            )..fetch(),
            child: const NavigateScreen(),
          ),
        ),
        // SettingsBloc is above every route, in App.
        GoRoute(
          path: 'settings',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    SetUnitsBloc(context.di<SettingsRepository>()),
              ),
              BlocProvider(
                create: (context) =>
                    SetLanguageBloc(context.di<SettingsRepository>()),
              ),
              BlocProvider(
                create: (context) =>
                    SetVibrationOnArrivalBloc(context.di<SettingsRepository>()),
              ),
            ],
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);

/// Until onboarding is done every route leads to it; afterwards it leads
/// Home (mvp-scope.md §2.6). An unreadable flag never locks the user out.
Future<String?> _onboardingFirst(
  BuildContext context,
  GoRouterState state,
) async {
  final completed =
      (await context.di<OnboardingRepository>().isCompleted()).valueOrNull ??
      true;
  final atOnboarding = state.matchedLocation == Routes.onboarding;
  if (!completed) return atOnboarding ? null : Routes.onboarding;
  return atOnboarding ? Routes.home : null;
}
