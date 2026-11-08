import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// GPS state for the screen it sits on: accuracy when there is a fix,
/// otherwise what is wrong and the action that fixes it.
///
/// Needs [LocationFixBloc], [RequestLocationPermissionBloc] and
/// [OpenLocationSettingsBloc] above it.
class GpsStatus extends StatefulWidget {
  const GpsStatus({super.key});

  @override
  State<GpsStatus> createState() => _GpsStatusState();
}

class _GpsStatusState extends State<GpsStatus> {
  late final AppLifecycleListener _lifecycle;

  /// Set when the user went to the system settings from here. Only then does
  /// coming back re-check access: a return from a system dialog that the
  /// location request itself raised must not request again, or it loops.
  bool _inSettings = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    if (!_inSettings) return;
    _inSettings = false;
    context.read<LocationFixBloc>().fetch();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<RequestLocationPermissionBloc, ActionState<LocationAccess>>(
        listener: (context, state) => state.mapOrNull(
          success: (_) => context.read<LocationFixBloc>().fetch(),
        ),
      ),
      BlocListener<OpenLocationSettingsBloc, ActionState<void>>(
        listener: (context, state) => state.mapOrNull(
          success: (_) {
            _inSettings = true;
            // The precise location dialog may have changed access already.
            context.read<LocationFixBloc>().fetch();
          },
        ),
      ),
    ],
    child: BlocBuilder<LocationFixBloc, DataState<LocationFix>>(
      builder: (context, state) {
        final child = state.map(
          initial: (_) => const _Locating(),
          loading: (s) => switch (s.previous) {
            final fix? => _Accuracy(fix),
            null => const _Locating(),
          },
          success: (s) => _Accuracy(s.data),
          failure: (s) => _FailureView(s.failure),
        );
        return WbStateSwitcher(
          // A weak signal adds a line: fade it in rather than jump.
          state: (child.runtimeType, state.dataOrNull?.isWeakSignal),
          animateSize: true,
          child: child,
        );
      },
    ),
  );
}

class _Locating extends StatelessWidget {
  const _Locating();

  @override
  Widget build(BuildContext context) =>
      WbProgress(label: context.l10n.pointCreateLocating);
}

class _Accuracy extends StatelessWidget {
  const _Accuracy(this.fix);

  final LocationFix fix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weak = fix.isWeakSignal;
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
            const SizedBox(width: WbSpacing.xs),
            Text(
              l10n.pointAccuracy(
                l10n.accuracy(
                  fix.accuracyMeters,
                  units: context.settings.units,
                ),
              ),
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

class _FailureView extends StatelessWidget {
  const _FailureView(this.failure);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = failure.code;
    final busy =
        context.watch<RequestLocationPermissionBloc>().state.isInProgress ||
        context.watch<OpenLocationSettingsBloc>().state.isInProgress;
    if (code == LocationErrorCodes.permissionDenied) {
      return _AlertWithAction(
        alert: WbAlert(
          title: l10n.permissionTitle,
          message: l10n.permissionBody,
          tone: WbTone.brand,
        ),
        action: l10n.actionAllow,
        busy: busy,
        onPressed: () =>
            context.read<RequestLocationPermissionBloc>().run(null),
      );
    }
    final text = l10n.error(code);
    final precise = code == LocationErrorCodes.preciseRequired;
    final opensSettings =
        precise ||
        code == LocationErrorCodes.permissionDeniedForever ||
        code == LocationErrorCodes.serviceDisabled;
    return _AlertWithAction(
      alert: WbAlert(
        title: text.title,
        message: text.body,
        tone: WbTone.negative,
      ),
      action: precise
          ? l10n.actionEnablePreciseLocation
          : opensSettings
          ? l10n.actionOpenSettings
          : l10n.actionRetry,
      busy: busy,
      onPressed: opensSettings
          ? () => context.read<OpenLocationSettingsBloc>().run(code)
          : context.read<LocationFixBloc>().fetch,
    );
  }
}

class _AlertWithAction extends StatelessWidget {
  const _AlertWithAction({
    required this.alert,
    required this.action,
    required this.busy,
    required this.onPressed,
  });

  final Widget alert;
  final String action;
  final bool busy;
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
        loading: busy,
        onPressed: onPressed,
      ),
    ],
  );
}
