import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// No guidance: the point is gone, there is no position, or location is only
/// approximate. Other access problems are fixed from the GPS status on Home,
/// so there the way out is a retry.
class NavigationErrorView extends StatefulWidget {
  const NavigationErrorView({
    required this.failure,
    required this.onRetry,
    required this.onEnablePrecise,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;
  final VoidCallback onEnablePrecise;

  @override
  State<NavigationErrorView> createState() => _NavigationErrorViewState();
}

class _NavigationErrorViewState extends State<NavigationErrorView> {
  late final AppLifecycleListener _lifecycle;

  bool get _precise =>
      widget.failure.code == LocationErrorCodes.preciseRequired;

  @override
  void initState() {
    super.initState();
    // Back from the system dialog or settings: access may have changed.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (_precise) widget.onRetry();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = l10n.error(widget.failure.code);
    final gone = widget.failure.code == PointsErrorCodes.notFound;
    return Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: WbSpacing.md,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: WbSpacing.md,
                    children: [
                      const WbDirectionIcon(Icons.location_off_outlined),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WbSpacing.md,
                        ),
                        child: Text(
                          text.title,
                          textAlign: TextAlign.center,
                          style: context.wbText.headlineSmall,
                        ),
                      ),
                      Text(
                        text.body,
                        textAlign: TextAlign.center,
                        style: context.wbText.bodyLarge?.copyWith(
                          color: context.wbColors.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          WbButton(
            label: _precise
                ? l10n.actionEnablePreciseLocation
                : gone
                ? l10n.pointBackToList
                : l10n.actionRetry,
            variant: WbButtonVariant.secondary,
            onPressed: _precise
                ? widget.onEnablePrecise
                : gone
                ? () => context.go(Routes.pointsList)
                : widget.onRetry,
          ),
        ],
      ),
    );
  }
}
