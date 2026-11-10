import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/distance_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_notice_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_stop_bloc.dart';

/// Keeps the background navigation notice in step with the guidance, and
/// closes navigation on its Stop (mvp-scope.md §2.8). The first fix starts
/// it: by then location access is known to be granted.
///
/// Needs [NavigationGuidanceBloc], [NavigationNoticeBloc] and
/// [NavigationStopBloc] above it.
class NavigationNoticeListener extends StatefulWidget {
  const NavigationNoticeListener({required this.child, super.key});

  /// How often a new distance reaches the notice; arrival does at once.
  static const updateInterval = Duration(seconds: 3);

  final Widget child;

  @override
  State<NavigationNoticeListener> createState() =>
      _NavigationNoticeListenerState();
}

class _NavigationNoticeListenerState extends State<NavigationNoticeListener> {
  final _sinceUpdate = Stopwatch();
  String? _shownText;
  bool? _shownArrived;

  void _update(NavigationGuidance guidance) {
    final l10n = context.l10n;
    final text = guidance.arrived
        // The title already names the point.
        ? l10n.navigateArrivedNotice
        : l10n.distance(guidance.distanceMeters, units: context.settings.units);
    if (text == _shownText) return;
    if (guidance.arrived == _shownArrived &&
        _sinceUpdate.elapsed < NavigationNoticeListener.updateInterval) {
      return;
    }
    _shownText = text;
    _shownArrived = guidance.arrived;
    _sinceUpdate
      ..reset()
      ..start();
    context.read<NavigationNoticeBloc>().run(
      NavigationNotice(
        title: guidance.point.name,
        text: text,
        stopLabel: l10n.navigateNotificationStop,
        channelName: l10n.navigateNotificationChannel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<NavigationGuidanceBloc, DataState<NavigationGuidance>>(
        listener: (_, state) {
          final guidance = state.mapOrNull(success: (s) => s.data);
          if (guidance != null) _update(guidance);
        },
      ),
      BlocListener<NavigationStopBloc, DataState<void>>(
        listenWhen: (_, current) =>
            current.mapOrNull(success: (_) => true) ?? false,
        listener: (context, _) => context.back(),
      ),
    ],
    child: widget.child,
  );
}
