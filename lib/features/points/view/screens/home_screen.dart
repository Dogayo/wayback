import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/widgets/stub_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.gpsStatus, super.key});

  /// Location state, supplied by the app so this feature does not depend on
  /// the location feature directly.
  final Widget? gpsStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StubScreen(
      title: l10n.homeTitle,
      message: l10n.screenStub,
      actions: [
        ?gpsStatus,
        WbButton(
          label: l10n.homeSaveLocation,
          onPressed: () => context.push(Routes.pointCreate),
        ),
        WbButton(
          label: l10n.homeAllPoints,
          variant: WbButtonVariant.secondary,
          onPressed: () => context.push(Routes.pointsList),
        ),
        WbButton(
          label: l10n.settingsTitle,
          variant: WbButtonVariant.secondary,
          onPressed: () => context.push(Routes.settings),
        ),
      ],
    );
  }
}
