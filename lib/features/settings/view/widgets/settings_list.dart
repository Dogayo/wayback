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
///
/// Rows run the full width and keep their own 16 dp inset, so every line of
/// text starts at the same place (03 · Screens, «Settings / Unified»).
class SettingsList extends StatelessWidget {
  const SettingsList(this.settings, {super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const languages = AppLanguage.values;
    return ListView(
      padding: context.wbScrollPadding.copyWith(left: 0, right: 0),
      children: [
        _SectionTitle(l10n.settingsUnits),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: WbSpacing.md),
          child: WbSegmentedTabs<UnitSystem>(
            items: {
              for (final units in UnitSystem.values)
                units: l10n.unitSystem(units),
            },
            value: settings.units,
            onChanged: context.read<SetUnitsBloc>().run,
          ),
        ),
        _SectionTitle(l10n.settingsLanguage),
        for (final language in languages)
          WbListItem(
            title: l10n.appLanguage(language),
            selected: language == settings.language,
            showDivider: language != languages.last,
            onTap: () {
              if (language != settings.language) {
                WbHaptics.play(context, WbHaptic.tick);
              }
              context.read<SetLanguageBloc>().run(language);
            },
          ),
        _SectionTitle(l10n.settingsGroupVibration),
        _SwitchRow(
          WbSwitch(
            value: settings.vibrationOnArrival,
            label: l10n.settingsVibration,
            onChanged: context.read<SetVibrationOnArrivalBloc>().run,
          ),
        ),
        if (settings.vibrationOnArrival)
          WbListItem(
            title: l10n.settingsVibrationPattern,
            subtitle: l10n.vibrationPattern(settings.vibrationPattern),
            trailing: const Icon(Icons.chevron_right),
            showDivider: true,
            onTap: () => context.push(Routes.vibrationType),
          ),
        _SwitchRow(
          WbSwitch(
            value: settings.touchFeedback,
            label: l10n.settingsTouchFeedback,
            onChanged: context.read<SetTouchFeedbackBloc>().run,
          ),
          divider: false,
        ),
        _SectionTitle(l10n.settingsGroupDiagnostics),
        WbListItem(
          title: l10n.settingsSendLog,
          subtitle: l10n.settingsSendLogHint,
          trailing: const Icon(Icons.chevron_right),
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
    padding: const EdgeInsets.fromLTRB(
      WbSpacing.md,
      WbSpacing.lg,
      WbSpacing.md,
      WbSpacing.xs,
    ),
    child: Text(
      text,
      style: context.wbText.labelMedium?.copyWith(
        color: context.wbColors.contentSecondary,
      ),
    ),
  );
}

/// A switch as one more 56 dp row of the list.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow(this.child, {this.divider = true});

  final WbSwitch child;
  final bool divider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: WbSpacing.md),
        alignment: Alignment.center,
        child: child,
      ),
      if (divider) const Divider(indent: WbSpacing.md, endIndent: WbSpacing.md),
    ],
  );
}
