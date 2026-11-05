import 'package:flutter/material.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Alert for a failure by its code, with one action under it.
class PointsErrorView extends StatelessWidget {
  const PointsErrorView({
    required this.failure,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final Failure failure;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final text = context.l10n.error(failure.code);
    return Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WbAlert(title: text.title, message: text.body, tone: WbTone.negative),
          const SizedBox(height: WbSpacing.sm),
          WbButton(
            label: actionLabel,
            variant: WbButtonVariant.secondary,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
