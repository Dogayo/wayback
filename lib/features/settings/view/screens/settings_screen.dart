import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/features/settings/view/bloc/send_log_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_touch_feedback_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';
import 'package:wayback/features/settings/view/widgets/settings_list.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Units, language and vibration on arrival (SCREENS.md §4.6).
///
/// Needs [SettingsBloc], [SetUnitsBloc], [SetLanguageBloc],
/// [SetVibrationOnArrivalBloc] and [SendLogBloc] above it.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SettingsBloc>().state;
    return MultiBlocListener(
      // A failed action keeps the screen as it was and says so. The controls
      // have already answered the tap.
      listeners: [
        ActionResultListener<SetUnitsBloc, void>(successHaptic: null),
        ActionResultListener<SetLanguageBloc, void>(successHaptic: null),
        ActionResultListener<SetVibrationOnArrivalBloc, void>(
          successHaptic: null,
        ),
        ActionResultListener<SetTouchFeedbackBloc, void>(successHaptic: null),
        ActionResultListener<SendLogBloc, void>(successHaptic: null),
      ],
      child: Scaffold(
        appBar: WbAppBar(title: l10n.settingsTitle, onBack: context.back),
        body: state.mapOrElse(
          success: (s) => SettingsList(s.data),
          failure: (s) => _Failure(s.failure.code),
          orElse: (_) => const _Loading(),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(WbSpacing.screenPadding),
    child: Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          const WbSkeleton(height: WbSpacing.xxxxxl),
          const SizedBox(height: WbSpacing.lg),
        ],
      ],
    ),
  );
}

class _Failure extends StatelessWidget {
  const _Failure(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = l10n.error(code);
    return Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WbAlert(title: text.title, message: text.body, tone: WbTone.negative),
          const SizedBox(height: WbSpacing.sm),
          WbButton(
            label: l10n.actionRetry,
            variant: WbButtonVariant.secondary,
            onPressed: context.read<SettingsBloc>().fetch,
          ),
        ],
      ),
    );
  }
}
