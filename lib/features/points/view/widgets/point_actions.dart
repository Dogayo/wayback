import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/points_with_distance.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/restore_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// What can be done to a point from any screen that shows one. Needs
/// [RenamePointBloc], [SetPointActiveBloc], [DeletePointBloc] and
/// [RestorePointBloc] above the `context`.
abstract final class PointActions {
  static Future<void> rename(BuildContext context, SavedPoint point) async {
    final l10n = context.l10n;
    final rename = context.read<RenamePointBloc>();
    final name = await WbDialogs.prompt(
      context,
      title: l10n.pointRenameTitle,
      initialValue: point.name,
      label: l10n.pointNameLabel,
      confirmLabel: l10n.actionSave,
      cancelLabel: l10n.actionCancel,
      maxLength: pointNameMaxLength,
      validator: (value) => value.isEmpty ? l10n.pointNameRequired : null,
    );
    if (name != null) rename.run((id: point.id, name: name));
  }

  static Future<void> delete(BuildContext context, SavedPoint point) async {
    final l10n = context.l10n;
    final delete = context.read<DeletePointBloc>();
    final confirmed = await WbDialogs.confirm(
      context,
      title: l10n.pointDeleteTitle(point.name),
      message: l10n.pointDeleteBody,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.actionCancel,
      destructive: true,
    );
    if (confirmed ?? false) delete.run(point);
  }

  static void toggleActive(BuildContext context, SavedPoint point) => context
      .read<SetPointActiveBloc>()
      .run((id: point.id, active: !point.isActive));

  /// Everything at once, for a long press.
  static Future<void> openSheet(BuildContext context, PointDistance item) {
    final l10n = context.l10n;
    final (:point, :distanceMeters) = item;
    // The row that was pressed can be gone by the time the sheet closes.
    VoidCallback ifMounted(VoidCallback action) => () {
      if (context.mounted) action();
    };
    return WbActionSheet.show(
      context,
      title: point.name,
      subtitle: l10n.distanceOrUnknown(
        distanceMeters,
        units: context.settings.units,
      ),
      icon: point.type.design.icon,
      actions: [
        WbSheetAction(
          icon: Icons.info_outline,
          label: l10n.pointActionDetails,
          onSelected: ifMounted(
            () => context.push(Routes.pointDetails(point.id)),
          ),
        ),
        WbSheetAction(
          icon: Icons.share_outlined,
          label: l10n.pointActionShare,
          onSelected: ifMounted(
            () => context.push(Routes.pointShare(point.id)),
          ),
        ),
        WbSheetAction(
          icon: Icons.edit_outlined,
          label: l10n.actionRename,
          onSelected: ifMounted(() => rename(context, point)),
        ),
        WbSheetAction(
          icon: point.isActive
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          label: point.isActive
              ? l10n.pointActionDeactivate
              : l10n.pointActionActivate,
          onSelected: ifMounted(() => toggleActive(context, point)),
        ),
        WbSheetAction(
          icon: Icons.delete_outline,
          label: l10n.actionDelete,
          destructive: true,
          onSelected: ifMounted(() => delete(context, point)),
        ),
      ],
    );
  }

  /// The same actions behind a row, for a swipe.
  static List<WbSwipeAction> swipe(BuildContext context, SavedPoint point) {
    final l10n = context.l10n;
    return [
      WbSwipeAction(
        icon: point.isActive
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        label: point.isActive
            ? l10n.pointSwipeDeactivate
            : l10n.pointSwipeActivate,
        onPressed: () => toggleActive(context, point),
      ),
      WbSwipeAction(
        icon: Icons.edit_outlined,
        label: l10n.actionRename,
        onPressed: () => rename(context, point),
      ),
      WbSwipeAction(
        icon: Icons.delete_outline,
        label: l10n.actionDelete,
        destructive: true,
        onPressed: () => delete(context, point),
      ),
    ];
  }

  static void showDeleted(BuildContext context, SavedPoint point) =>
      _offerUndo(context, context.l10n.pointDeletedSnackbar(point.name), point);

  static void _offerUndo(
    BuildContext context,
    String message,
    SavedPoint restored,
  ) {
    final restore = context.read<RestorePointBloc>();
    WbUndoSnackbar.show(
      context,
      message: message,
      actionLabel: context.l10n.actionUndo,
      onUndo: () => restore.run(restored),
    );
  }
}

/// Reports how [PointActions] went on a screen that lists points.
class PointActionsListener extends StatelessWidget {
  const PointActionsListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      ActionResultListener<DeletePointBloc, SavedPoint>(
        successHaptic: WbHaptic.press,
        onSuccess: PointActions.showDeleted,
      ),
      ActionResultListener<RenamePointBloc, SavedPoint>(
        successHaptic: WbHaptic.tick,
      ),
      ActionResultListener<SetPointActiveBloc, SavedPoint>(
        successHaptic: WbHaptic.tick,
        onSuccess: (context, point) {
          if (point.isActive) return;
          PointActions._offerUndo(
            context,
            context.l10n.pointDeactivatedSnackbar(point.name),
            point.copyWith(isActive: true),
          );
        },
      ),
    ],
    child: child,
  );
}
