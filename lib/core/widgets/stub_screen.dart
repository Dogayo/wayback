import 'package:flutter/material.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Temporary screen body until a feature implements the real one.
class StubScreen extends StatelessWidget {
  const StubScreen({
    required this.title,
    required this.message,
    this.onBack,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: WbAppBar(title: title, onBack: onBack),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(WbSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: WbSpacing.md,
          children: [Text(message), ...actions],
        ),
      ),
    ),
  );
}
