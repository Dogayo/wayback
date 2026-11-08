import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/point_type_l10n.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/open_fix_settings_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_fix_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/bottom_action_bar.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Name and type for the point at the current position (SCREENS.md §4.2).
///
/// Needs [PointFormBloc], [PointFixBloc], [SavePointBloc] and
/// [OpenFixSettingsBloc] above it.
class PointCreateScreen extends StatefulWidget {
  const PointCreateScreen({super.key});

  @override
  State<PointCreateScreen> createState() => _PointCreateScreenState();
}

class _PointCreateScreenState extends State<PointCreateScreen> {
  late final TextEditingController _name;
  late final AppLifecycleListener _lifecycle;

  /// Set when the user went to the system settings from here; only then does
  /// coming back look for a fix again (a system dialog raised by the location
  /// request itself must not trigger another request, or it loops).
  bool _inSettings = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<PointFormBloc>().state.name,
    );
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    if (!_inSettings) return;
    _inSettings = false;
    context.read<PointFixBloc>().fetch();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _name.dispose();
    super.dispose();
  }

  void _onSaved(BuildContext context, ActionState<SavedPoint> state) =>
      state.mapOrNull(
        success: (s) {
          WbSnackbar.show(
            context,
            context.l10n.pointSavedSnackbar(s.result.name),
          );
          context.pop();
        },
        failure: (s) =>
            WbSnackbar.show(context, context.l10n.error(s.failure.code).title),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = context.watch<PointFormBloc>().state;
    final fix = context.watch<PointFixBloc>().state;
    final saving = context.watch<SavePointBloc>().state.isInProgress;
    return MultiBlocListener(
      listeners: [
        BlocListener<PointFormBloc, PointFormState>(
          // A default name follows the chosen type until the user edits it.
          listener: (_, state) {
            if (!state.nameEdited && _name.text != state.name) {
              _name.text = state.name;
            }
          },
        ),
        BlocListener<SavePointBloc, ActionState<SavedPoint>>(
          listener: _onSaved,
        ),
        BlocListener<OpenFixSettingsBloc, ActionState<void>>(
          listener: (context, state) => state.mapOrNull(
            success: (_) {
              _inSettings = true;
              // The precise location dialog may have changed access already.
              context.read<PointFixBloc>().fetch();
            },
          ),
        ),
      ],
      child: Scaffold(
        appBar: WbAppBar(title: l10n.pointCreateTitle, onBack: context.back),
        body: ListView(
          padding: const EdgeInsets.all(WbSpacing.screenPadding),
          children: [
            WbTextField(
              controller: _name,
              label: l10n.pointNameLabel,
              helper: l10n.pointNameHelper,
              onChanged: (name) =>
                  context.read<PointFormBloc>().add(PointFormNameEdited(name)),
            ),
            const SizedBox(height: WbSpacing.lg),
            Text(
              l10n.pointTypeLabel,
              style: context.wbText.labelMedium?.copyWith(
                color: context.wbColors.contentSecondary,
              ),
            ),
            const SizedBox(height: WbSpacing.xs),
            WbTypePicker(
              value: form.type.design,
              labelOf: l10n.pointType,
              onChanged: (type) => context.read<PointFormBloc>().add(
                PointFormTypeSelected(type.domain),
              ),
            ),
            const SizedBox(height: WbSpacing.lg),
            WbStateSwitcher(
              animateSize: true,
              child: fix.map(
                initial: (_) => WbProgress(label: l10n.pointCreateLocating),
                loading: (_) => WbProgress(label: l10n.pointCreateLocating),
                success: (s) => _Position(fix: s.data),
                failure: (s) => _FixFailure(s.failure),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          children: [
            WbButton(
              label: l10n.actionSave,
              loading: saving,
              onPressed: fix.mapOrNull(
                success: (s) =>
                    () => context.read<SavePointBloc>().run((
                      name: form.resolvedName,
                      type: form.type,
                      fix: s.data,
                    )),
              ),
            ),
            WbButton(
              label: l10n.actionCancel,
              variant: WbButtonVariant.tertiary,
              onPressed: context.back,
            ),
          ],
        ),
      ),
    );
  }
}

class _FixFailure extends StatelessWidget {
  const _FixFailure(this.failure);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = l10n.error(failure.code);
    final precise = failure.code == LocationErrorCodes.preciseRequired;
    final opensSettings =
        precise ||
        failure.code == LocationErrorCodes.serviceDisabled ||
        failure.code == LocationErrorCodes.permissionDeniedForever;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WbAlert(title: text.title, message: text.body, tone: WbTone.negative),
        const SizedBox(height: WbSpacing.sm),
        WbButton(
          label: precise
              ? l10n.actionEnablePreciseLocation
              : opensSettings
              ? l10n.actionOpenSettings
              : l10n.actionRetry,
          variant: WbButtonVariant.secondary,
          onPressed: opensSettings
              ? () => context.read<OpenFixSettingsBloc>().run(failure.code)
              : context.read<PointFixBloc>().fetch,
        ),
      ],
    );
  }
}

class _Position extends StatelessWidget {
  const _Position({required this.fix});

  final LocationFix fix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final secondary = context.wbColors.contentSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pointCoordinatesLabel,
          style: context.wbText.labelMedium?.copyWith(color: secondary),
        ),
        Text(formatCoordinates(fix.point), style: context.wbText.bodyLarge),
        Text(
          l10n.pointAccuracy(
            l10n.accuracy(fix.accuracyMeters, units: context.settings.units),
          ),
          style: context.wbText.bodySmall?.copyWith(
            color: fix.isWeakSignal ? context.wbColors.warning : secondary,
          ),
        ),
      ],
    );
  }
}
