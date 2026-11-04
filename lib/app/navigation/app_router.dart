import 'package:go_router/go_router.dart';

import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';

/// Every screen is a child of `/`, so a deep link to `/points/:id` keeps
/// Home under it and "back" leads to `/` (SCREENS.md §3).
GoRouter createRouter({String initialLocation = Routes.home}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (_, _) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'points/new',
          builder: (_, _) => const PointCreateScreen(),
        ),
        GoRoute(path: 'points', builder: (_, _) => const PointsListScreen()),
        GoRoute(
          path: 'points/:${Routes.pointIdParam}',
          builder: (_, state) => PointDetailsScreen(
            pointId: state.pathParameters[Routes.pointIdParam]!,
          ),
        ),
        GoRoute(
          path: 'navigate/:${Routes.pointIdParam}',
          builder: (_, state) => NavigateScreen(
            pointId: state.pathParameters[Routes.pointIdParam]!,
          ),
        ),
        GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);
