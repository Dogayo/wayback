/// Route names and paths. The only place where route strings live.
abstract final class Routes {
  static const home = '/';
  static const pointCreate = '/points/new';
  static const pointsList = '/points';
  static const settings = '/settings';

  /// First launch only; outside the `/` stack (architecture.md §6).
  static const onboarding = '/onboarding';

  static String pointDetails(String id) => '/points/$id';
  static String navigate(String id) => '/navigate/$id';

  static const pointIdParam = 'id';
}
