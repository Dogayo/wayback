import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Listens to an [ActionBloc] and gives the standard response to its result,
/// so that no screen can forget it (DESIGN_SYSTEM.md, «Отклик»).
///
/// [successHaptic] is required on purpose: `null` has to be a decision. A
/// control that already answered the tap, like a switch, passes `null`.
///
/// A failure warns and shows its text. With [reportFailure] off it stays
/// silent, for actions the user did not ask for or a screen that moves on
/// whatever happens.
class ActionResultListener<B extends StateStreamable<ActionState<T>>, T>
    extends BlocListener<B, ActionState<T>> {
  ActionResultListener({
    required WbHaptic? successHaptic,
    void Function(BuildContext context, T result)? onSuccess,
    VoidCallback? onFailure,
    bool reportFailure = true,
    super.child,
    super.key,
  }) : super(
         listener: (context, state) => state.mapOrNull(
           success: (s) {
             if (successHaptic != null) {
               WbHaptics.play(context, successHaptic);
             }
             onSuccess?.call(context, s.result);
           },
           failure: (s) {
             if (reportFailure) {
               WbHaptics.play(context, WbHaptic.warning);
               WbSnackbar.show(
                 context,
                 context.l10n.error(s.failure.code).title,
               );
             }
             onFailure?.call();
           },
         ),
       );
}
