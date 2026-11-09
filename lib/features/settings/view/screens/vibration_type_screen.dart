import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/settings_l10n.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_pattern_bloc.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';
import 'package:wayback/features/settings/view/bloc/test_vibration_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// The vibration played on arrival, with a way to feel it first
/// (SCREENS.md §4.6).
///
/// Needs [SettingsBloc], [SetVibrationPatternBloc] and [TestVibrationBloc]
/// above it.
class VibrationTypeScreen extends StatelessWidget {
  const VibrationTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected =
        context.watch<SettingsBloc>().state.dataOrNull?.vibrationPattern ??
        AppSettings.defaults.vibrationPattern;
    return MultiBlocListener(
      listeners: [
        ActionResultListener<SetVibrationPatternBloc, void>(
          successHaptic: null,
        ),
        ActionResultListener<TestVibrationBloc, void>(successHaptic: null),
      ],
      child: Scaffold(
        appBar: WbAppBar(
          title: l10n.settingsVibrationPattern,
          onBack: context.back,
        ),
        body: ListView(
          padding: const EdgeInsets.all(WbSpacing.screenPadding),
          children: [
            Text(
              l10n.settingsVibrationPatternHint,
              style: context.wbText.bodyMedium?.copyWith(
                color: context.wbColors.contentSecondary,
              ),
            ),
            const SizedBox(height: WbSpacing.sm),
            for (final pattern in VibrationPattern.values)
              WbListItem(
                title: l10n.vibrationPattern(pattern),
                selected: pattern == selected,
                onTap: () {
                  if (pattern != selected) {
                    WbHaptics.play(context, WbHaptic.tick);
                  }
                  context.read<SetVibrationPatternBloc>().run(pattern);
                },
              ),
            const SizedBox(height: WbSpacing.lg),
            WbButton(
              label: l10n.settingsVibrationTest,
              variant: WbButtonVariant.secondary,
              onPressed: () => context.read<TestVibrationBloc>().run(selected),
            ),
          ],
        ),
      ),
    );
  }
}
