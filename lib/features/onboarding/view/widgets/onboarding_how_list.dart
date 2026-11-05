import 'package:flutter/material.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Numbered steps of the main scenario and a note under them.
class OnboardingHowList extends StatelessWidget {
  const OnboardingHowList({required this.steps, required this.note, super.key});

  final List<String> steps;
  final String note;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: WbSpacing.sm,
    children: [
      for (final (i, step) in steps.indexed) _Step(number: i + 1, text: step),
      Text(
        note,
        textAlign: TextAlign.center,
        style: context.wbText.bodyMedium?.copyWith(
          color: context.wbColors.contentTertiary,
        ),
      ),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    spacing: WbSpacing.sm,
    children: [
      ExcludeSemantics(
        child: CircleAvatar(
          radius: WbSpacing.md,
          backgroundColor: context.wbColors.surfaceContainer,
          child: Text(
            number.toString(),
            style: context.wbText.labelLarge?.copyWith(
              color: context.wbColors.brand600,
            ),
          ),
        ),
      ),
      Expanded(child: Text(text, style: context.wbText.bodyLarge)),
    ],
  );
}
