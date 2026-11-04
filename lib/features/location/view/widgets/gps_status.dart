import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_cubit.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// GPS state for the screen it sits on: accuracy when there is a fix,
/// otherwise what is wrong and the action that fixes it.
///
/// Re-checks access when the app returns from the system settings.
class GpsStatus extends StatefulWidget {
  const GpsStatus({super.key});

  @override
  State<GpsStatus> createState() => _GpsStatusState();
}

class _GpsStatusState extends State<GpsStatus> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _recheck);
  }

  void _recheck() {
    final cubit = context.read<LocationCubit>();
    if (cubit.state is! LocationReady) cubit.start();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) => switch (state) {
          LocationLoading() => WbProgress(
            label: context.l10n.pointCreateLocating,
          ),
          LocationPermissionNeeded() => _AlertWithAction(
            alert: WbAlert(
              title: context.l10n.permissionTitle,
              message: context.l10n.permissionBody,
              tone: WbTone.brand,
            ),
            action: context.l10n.actionAllow,
            onPressed: context.read<LocationCubit>().requestPermission,
          ),
          LocationReady(:final fix) => _Accuracy(
            meters: fix.accuracyMeters,
            weak: fix.isWeakSignal,
          ),
          LocationError(:final failure) => _ErrorView(code: failure.code),
        },
      );
}

class _Accuracy extends StatelessWidget {
  const _Accuracy({required this.meters, required this.weak});

  final double meters;
  final bool weak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = weak
        ? context.wbColors.warning
        : context.wbColors.contentSecondary;
    final style = context.wbText.bodySmall?.copyWith(color: color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              weak ? Icons.gps_not_fixed : Icons.my_location,
              size: WbIconSize.sm,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.pointAccuracy(l10n.accuracyValue('${meters.round()}')),
              style: style,
            ),
          ],
        ),
        if (weak) ...[
          const SizedBox(height: WbSpacing.xxs),
          Text(l10n.navigateWeakSignal, style: style),
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LocationCubit>();
    final text = l10n.error(code);
    final (action, onPressed) = switch (code) {
      LocationErrorCodes.permissionDenied => (
        l10n.actionAllow,
        cubit.requestPermission,
      ),
      LocationErrorCodes.permissionDeniedForever ||
      LocationErrorCodes.serviceDisabled => (
        l10n.actionOpenSettings,
        cubit.openSettings,
      ),
      _ => (l10n.actionRetry, cubit.start),
    };
    return _AlertWithAction(
      alert: WbAlert(
        title: text.title,
        message: text.body,
        tone: WbTone.negative,
      ),
      action: action,
      onPressed: onPressed,
    );
  }
}

class _AlertWithAction extends StatelessWidget {
  const _AlertWithAction({
    required this.alert,
    required this.action,
    required this.onPressed,
  });

  final Widget alert;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      alert,
      const SizedBox(height: WbSpacing.sm),
      WbButton(
        label: action,
        variant: WbButtonVariant.secondary,
        onPressed: onPressed,
      ),
    ],
  );
}
