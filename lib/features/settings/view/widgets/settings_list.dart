import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/settings_l10n.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/view/bloc/send_log_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_language_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_touch_feedback_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_units_bloc.dart';
import 'package:wayback/features/settings/view/bloc/set_vibration_on_arrival_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Units, language and vibration, every change saved right away, and the
/// way to send the diagnostic log.
class SettingsList extends StatelessWidget {
  const SettingsList(this.settings, {super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: context.wbScrollPadding,
      children: [
        _SectionTitle(l10n.settingsUnits),
        WbSegmentedTabs<UnitSystem>(
          items: {
            for (final units in UnitSystem.values)
              units: l10n.unitSystem(units),
          },
          value: settings.units,
          onChanged: context.read<SetUnitsBloc>().run,
        ),
        const SizedBox(height: WbSpacing.lg),
        _SectionTitle(l10n.settingsLanguage),
        for (final language in AppLanguage.values)
          WbListItem(
            title: l10n.appLanguage(language),
            selected: language == settings.language,
            onTap: () {
              if (language != settings.language) {
                WbHaptics.play(context, WbHaptic.tick);
              }
              context.read<SetLanguageBloc>().run(language);
            },
          ),
        const SizedBox(height: WbSpacing.lg),
        WbSwitch(
          value: settings.vibrationOnArrival,
          label: l10n.settingsVibration,
          onChanged: context.read<SetVibrationOnArrivalBloc>().run,
        ),
        if (settings.vibrationOnArrival)
          WbListItem(
            title: l10n.settingsVibrationPattern,
            subtitle: l10n.vibrationPattern(settings.vibrationPattern),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.vibrationType),
          ),
        WbSwitch(
          value: settings.touchFeedback,
          label: l10n.settingsTouchFeedback,
          onChanged: context.read<SetTouchFeedbackBloc>().run,
        ),
        const SizedBox(height: WbSpacing.lg),
        WbListItem(
          title: l10n.settingsSendLog,
          subtitle: l10n.settingsSendLogHint,
          onTap: () =>
              context.read<SendLogBloc>().run(l10n.diagnosticsShareSubject),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: WbSpacing.xs),
    child: Text(
      text,
      style: context.wbText.labelMedium?.copyWith(
        color: context.wbColors.contentSecondary,
      ),
    ),
  );
}
