import 'package:flutter/material.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// One onboarding page: illustration or [visual], title and either a [body] text or
/// custom [content] (SCREENS.md §4.0).
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({
    required this.title,
    this.illustration,
    this.visual,
    this.body,
    this.content,
    super.key,
  });

  final WbIllustrationKind? illustration;

  /// Takes the place of [illustration].
  final Widget? visual;
  final String title;
  final String? body;
  final Widget? content;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: WbSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: WbSpacing.md,
        children: [
          ?visual,
          if (illustration case final kind?) WbIllustration(kind),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.wbText.headlineSmall,
          ),
          if (body case final body?)
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.wbText.bodyLarge?.copyWith(
                color: context.wbColors.contentSecondary,
              ),
            ),
          ?content,
        ],
      ),
    ),
  );
}
