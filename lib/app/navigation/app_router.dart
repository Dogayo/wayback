import 'package:app_di/app_di.dart';
import 'package:app_logger/app_logger.dart';
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
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';
import 'package:wayback/features/navigation/view/bloc/arrival_vibration_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/enable_precise_location_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_notice_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_stop_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback/features/navigation/view/widgets/point_direction.dart';
import 'package:wayback/features/navigation/view/widgets/point_directions_gate.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:wayback/features/onboarding/view/bloc/finish_onboarding_bloc.dart';
import 'package:wayback/features/onboarding/view/screens/onboarding_screen.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/edit_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/open_fix_settings_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_fix_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_import_bloc.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';
import 'package:wayback/features/points/view/bloc/quick_save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/bloc/share_point_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';
import 'package:wayback/features/points/view/screens/point_import_screen.dart';
import 'package:wayback/features/points/view/screens/point_share_screen.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';
import 'package:wayback/features/settings/view/bloc/send_log_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_theme_mode_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_touch_feedback_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_pattern_bloc.dart';
import 'package:wayback/features/settings/view/bloc/test_vibration_bloc.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';
import 'package:wayback/features/settings/view/screens/vibration_type_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

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
      pageBuilder: _page(
        (_, state) => BlocProvider(
          create: (context) => FinishOnboardingBloc(
            context.di<OnboardingRepository>(),
            context.di<LocationRepository>(),
          ),
          child: OnboardingScreen(
            next: _importAfterOnboarding(state.uri.queryParameters['next']),
          ),
        ),
        WbTransition.fade,
      ),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: _page((context, _) {
        final l10n = context.l10n;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => QuickSavePointBloc(
                context.di<PointsRepository>(),
                context.di<LocationRepository>(),
                label: l10n.pointType(PointType.generic.design),
                numbered: l10n.pointDefaultNameNumbered,
              ),
            ),
            BlocProvider(
              create: (context) =>
                  EditPointBloc(context.di<PointsRepository>()),
            ),
            BlocProvider(
              create: (context) =>
                  SetPointActiveBloc(context.di<PointsRepository>()),
            ),
            BlocProvider(
              create: (context) =>
                  DeletePointBloc(context.di<PointsRepository>()),
            ),
            BlocProvider(
              lazy: false,
              create: (context) =>
                  LocationFixBloc(context.di<LocationRepository>())..fetch(),
            ),
            BlocProvider(
              create: (context) => RequestLocationPermissionBloc(
                context.di<LocationRepository>(),
              ),
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
            BlocProvider(
              create: (context) => PointDirectionsBloc(
                context.di<PointsRepository>(),
                context.di<LocationRepository>(),
                context.di<CompassRepository>(),
              ),
            ),
          ],
          child: PointDirectionsGate(
            child: HomeScreen(
              gpsStatus: const GpsStatus(),
              direction: (pointId, icon) => PointDirection(pointId, icon: icon),
              largeDirection: (pointId, icon) =>
                  PointDirection(pointId, icon: icon, large: true),
            ),
          ),
        );
      }, WbTransition.fade),
      routes: [
        GoRoute(
          path: 'import',
          pageBuilder: _page((context, state) {
            final l10n = context.l10n;
            final text = pointImportText(state.uri.queryParameters);
            final draft = parsePointText(text);
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => PointFormBloc(
                    context.di<PointsRepository>(),
                    labelOf: (type) => l10n.pointType(type.design),
                    numbered: l10n.pointDefaultNameNumbered,
                    name: draft?.name,
                    type: draft?.type ?? PointType.generic,
                  )..add(const PointFormStarted()),
                ),
                BlocProvider(
                  create: (context) => PointImportBloc(
                    context.di<PointsRepository>(),
                    context.di<LocationRepository>(),
                    text: text,
                  )..add(const PointImportStarted()),
                ),
                BlocProvider(
                  create: (context) =>
                      SavePointBloc(context.di<PointsRepository>()),
                ),
              ],
              child: PointImportScreen(received: text.isNotEmpty),
            );
          }, WbTransition.modal),
        ),
        GoRoute(
          path: 'points/new',
          pageBuilder: _page((context, _) {
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
          }, WbTransition.modal),
        ),
        GoRoute(
          path: 'points',
          pageBuilder: _page(
            (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => PointsListBloc(
                    context.di<PointsRepository>(),
                    context.di<LocationRepository>(),
                  )..fetch(),
                ),
                BlocProvider(
                  create: (context) =>
                      EditPointBloc(context.di<PointsRepository>()),
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
              child: const PointsListScreen(),
            ),
            WbTransition.drill,
          ),
        ),
        GoRoute(
          path: 'points/:${Routes.pointIdParam}',
          pageBuilder: _page(
            (_, state) => MultiBlocProvider(
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
                      EditPointBloc(context.di<PointsRepository>()),
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
            WbTransition.drill,
          ),
        ),
        GoRoute(
          path: 'points/:${Routes.pointIdParam}/share',
          pageBuilder: _page(
            (_, state) => MultiBlocProvider(
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
                      SharePointBloc(context.di<PointShareRepository>()),
                ),
              ],
              child: const PointShareScreen(),
            ),
            WbTransition.drill,
          ),
        ),
        GoRoute(
          path: 'navigate/:${Routes.pointIdParam}',
          pageBuilder: _page(
            (_, state) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => NavigationGuidanceBloc(
                    context.di<PointsRepository>(),
                    context.di<LocationRepository>(),
                    context.di<CompassRepository>(),
                    pointId: state.pathParameters[Routes.pointIdParam]!,
                    logger: context.di<AppLogger>(),
                  )..fetch(),
                ),
                BlocProvider(
                  create: (context) => EnablePreciseLocationBloc(
                    context.di<LocationRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      ArrivalVibrationBloc(context.di<VibrationRepository>()),
                ),
                BlocProvider(
                  create: (context) => NavigationNoticeBloc(
                    context.di<BackgroundNavigationRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => NavigationStopBloc(
                    context.di<BackgroundNavigationRepository>(),
                  )..fetch(),
                ),
              ],
              child: const NavigateScreen(),
            ),
            WbTransition.enterMode,
          ),
        ),
        // SettingsBloc is above every route, in App.
        GoRoute(
          path: 'settings',
          pageBuilder: _page(
            (_, _) => MultiBlocProvider(
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
                      SetThemeModeBloc(context.di<SettingsRepository>()),
                ),
                BlocProvider(
                  create: (context) => SetVibrationOnArrivalBloc(
                    context.di<SettingsRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      SetTouchFeedbackBloc(context.di<SettingsRepository>()),
                ),
                BlocProvider(
                  create: (context) =>
                      SendLogBloc(context.di<DiagnosticsRepository>()),
                ),
              ],
              child: const SettingsScreen(),
            ),
            WbTransition.drill,
          ),
          routes: [
            GoRoute(
              path: 'vibration',
              pageBuilder: _page(
                (_, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => SetVibrationPatternBloc(
                        context.di<SettingsRepository>(),
                      ),
                    ),
                    BlocProvider(
                      create: (context) =>
                          TestVibrationBloc(context.di<VibrationRepository>()),
                    ),
                  ],
                  child: const VibrationTypeScreen(),
                ),
                WbTransition.drill,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// A screen that comes in with [transition] (05 · Motion).
GoRouterPageBuilder _page(
  GoRouterWidgetBuilder builder,
  WbTransition transition,
) =>
    (context, state) => WbPage<void>(
      key: state.pageKey,
      name: state.matchedLocation,
      transition: transition,
      child: builder(context, state),
    );

/// Where to go after onboarding: only ever the import screen, whatever the
/// link says.
String? _importAfterOnboarding(String? next) =>
    next != null && next.startsWith(Routes.pointImport) ? next : null;

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
  if (!completed) {
    if (atOnboarding) return null;
    // A point someone sent must survive the first launch.
    if (state.matchedLocation == Routes.pointImport) {
      return Uri(
        path: Routes.onboarding,
        queryParameters: {
          'next': Uri(
            path: Routes.pointImport,
            query: state.uri.query,
          ).toString(),
        },
      ).toString();
    }
    return Routes.onboarding;
  }
  return atOnboarding ? Routes.home : null;
}
