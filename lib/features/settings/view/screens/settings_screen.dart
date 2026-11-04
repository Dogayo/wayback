import 'package:flutter/material.dart';

import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/widgets/stub_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => StubScreen(
    title: context.l10n.settingsTitle,
    message: context.l10n.screenStub,
    onBack: context.back,
  );
}
