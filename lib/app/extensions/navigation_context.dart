import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:wayback/app/navigation/routes.dart';

extension NavigationContext on BuildContext {
  /// Pops the current route, or goes Home when the screen was opened directly.
  void back() => canPop() ? pop() : go(Routes.home);
}
