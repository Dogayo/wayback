import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// No guidance: the point is gone, or there is no position. Access problems
/// are fixed from the GPS status on Home, so here the way out is a retry.
class NavigationErrorView extends StatelessWidget {
  const NavigationErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = l10n.error(failure.code);
    final gone = failure.code == PointsErrorCodes.notFound;
    return Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: WbSpacing.sm,
        children: [
          WbAlert(title: text.title, message: text.body, tone: WbTone.negative),
          WbButton(
            label: gone ? l10n.pointBackToList : l10n.actionRetry,
            variant: WbButtonVariant.secondary,
            onPressed: gone ? () => context.go(Routes.pointsList) : onRetry,
          ),
        ],
      ),
    );
  }
}
