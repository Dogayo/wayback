import 'package:flutter/material.dart';

import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/widgets/stub_screen.dart';

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({required this.pointId, super.key});

  final String pointId;

  @override
  Widget build(BuildContext context) => StubScreen(
    title: context.l10n.navigateTitle,
    message: context.l10n.screenStub,
    onBack: context.back,
  );
}
