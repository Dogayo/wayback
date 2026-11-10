import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/share_point_bloc.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Passing one point on to someone else (SCREENS.md §4.4a). Nothing leaves
/// the phone unless the user sends it.
///
/// Needs [PointDetailsBloc] and [SharePointBloc] above it.
class PointShareScreen extends StatelessWidget {
  const PointShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PointDetailsBloc>().state;
    return ActionResultListener<SharePointBloc, void>(
      successHaptic: null,
      child: Scaffold(
        appBar: WbAppBar(title: l10n.pointShareTitle, onBack: context.back),
        body: WbStateSwitcher(
          child: state.map(
            initial: (_) => const SizedBox.shrink(),
            loading: (s) => switch (s.previous) {
              final item? => _Content(item.point),
              null => const SizedBox.shrink(),
            },
            success: (s) => _Content(s.data.point),
            failure: (s) => PointsErrorView(
              failure: s.failure,
              actionLabel: l10n.pointBackToList,
              onAction: () => context.go(Routes.pointsList),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.point);

  final SavedPoint point;

  Future<void> _copy(BuildContext context) async {
    final copied = context.l10n.pointCoordinatesCopied;
    WbHaptics.play(context, WbHaptic.tick);
    await Clipboard.setData(
      ClipboardData(text: formatCoordinates(point.position)),
    );
    if (context.mounted) WbSnackbar.show(context, copied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sharing = context.watch<SharePointBloc>().state.isInProgress;
    return ListView(
      padding: context.wbScrollPadding,
      children: [
        const SizedBox(height: WbSpacing.sm),
        Text(
          point.name,
          textAlign: TextAlign.center,
          style: context.wbText.headlineSmall,
        ),
        const SizedBox(height: WbSpacing.xxs),
        Text(
          formatCoordinates(point.position),
          textAlign: TextAlign.center,
          style: context.wbText.bodyLarge?.copyWith(
            color: context.wbColors.contentSecondary,
          ),
        ),
        const SizedBox(height: WbSpacing.lg),
        WbQrCode(
          data: pointShareLink(point),
          semanticLabel: l10n.pointShareQrLabel,
        ),
        const SizedBox(height: WbSpacing.sm),
        Text(
          l10n.pointShareQrHint,
          textAlign: TextAlign.center,
          style: context.wbText.bodyMedium?.copyWith(
            color: context.wbColors.contentSecondary,
          ),
        ),
        const SizedBox(height: WbSpacing.xl),
        WbButton(
          label: l10n.pointShareSend,
          loading: sharing,
          onPressed: () => context.read<SharePointBloc>().run(point),
        ),
        const SizedBox(height: WbSpacing.sm),
        WbButton(
          label: l10n.pointShareCopy,
          variant: WbButtonVariant.secondary,
          onPressed: () => _copy(context),
        ),
      ],
    );
  }
}
