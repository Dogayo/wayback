import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/widgets/stub_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Placeholder id so the details route can be opened before points exist.
const _samplePointId = 'sample';

class PointsListScreen extends StatelessWidget {
  const PointsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StubScreen(
      title: l10n.pointsListTitle,
      message: l10n.screenStub,
      onBack: context.back,
      actions: [
        WbButton(
          label: l10n.pointsOpenSample,
          onPressed: () => context.push(Routes.pointDetails(_samplePointId)),
        ),
      ],
    );
  }
}
