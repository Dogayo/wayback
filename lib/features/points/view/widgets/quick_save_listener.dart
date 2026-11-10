import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/edit_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/quick_save_point_bloc.dart';
import 'package:wayback/features/points/view/widgets/point_actions.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Answers the one-tap save: a snackbar that offers to edit the new point, or
/// the form when saving at once was not possible. Needs [QuickSavePointBloc]
/// and [EditPointBloc] above it.
class QuickSaveListener extends StatelessWidget {
  const QuickSaveListener({required this.child, super.key});

  final Widget child;

  void _onDone(BuildContext context, SavedPoint? point) {
    if (point == null) {
      context.push(Routes.pointCreate);
      return;
    }
    WbHaptics.play(context, WbHaptic.success);
    final l10n = context.l10n;
    WbSnackbar.show(
      context,
      l10n.pointQuickSavedSnackbar(point.name),
      actionLabel: l10n.actionEdit,
      onAction: () => PointActions.edit(context, point),
    );
  }

  @override
  Widget build(BuildContext context) =>
      ActionResultListener<QuickSavePointBloc, SavedPoint?>(
        successHaptic: null,
        onSuccess: _onDone,
        child: child,
      );
}
