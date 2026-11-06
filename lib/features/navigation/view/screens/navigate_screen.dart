import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/view/bloc/arrival_vibration_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/enable_precise_location_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/widgets/navigation_error_view.dart';
import 'package:wayback/features/navigation/view/widgets/navigation_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Direction and distance to a point in real time (SCREENS.md §4.5).
///
/// Needs [NavigationGuidanceBloc], [EnablePreciseLocationBloc] and
/// [ArrivalVibrationBloc] above it. Vibrates when the user walks into the
/// arrival radius, unless the user turned it off; opening the screen already
/// inside the radius is not an arrival (mvp-scope.md §2.4).
class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

  static bool _arrivedNow(
    DataState<NavigationGuidance> previous,
    DataState<NavigationGuidance> current,
  ) =>
      !(previous.dataOrNull?.arrived ?? true) &&
      (current.mapOrNull(success: (s) => s.data.arrived) ?? false);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<NavigationGuidanceBloc>();
    return BlocListener<NavigationGuidanceBloc, DataState<NavigationGuidance>>(
      listenWhen: _arrivedNow,
      listener: (context, _) {
        if (context.settings.vibrationOnArrival) {
          context.read<ArrivalVibrationBloc>().run(null);
        }
      },
      child: BlocBuilder<NavigationGuidanceBloc, DataState<NavigationGuidance>>(
        builder: (context, state) => Scaffold(
          appBar: WbAppBar(
            title: state.dataOrNull?.point.name ?? l10n.navigateTitle,
            onBack: context.back,
          ),
          body: state.map(
            initial: (_) => const _Locating(),
            loading: (s) => switch (s.previous) {
              final guidance? => NavigationView(guidance),
              null => const _Locating(),
            },
            success: (s) => NavigationView(s.data),
            // A lost fix is shown as such, not as stale numbers.
            failure: (s) => NavigationErrorView(
              failure: s.failure,
              onRetry: bloc.fetch,
              onEnablePrecise: () =>
                  context.read<EnablePreciseLocationBloc>().run(null),
            ),
          ),
        ),
      ),
    );
  }
}

class _Locating extends StatelessWidget {
  const _Locating();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(WbSpacing.screenPadding),
      child: WbProgress(label: context.l10n.navigateLocating),
    ),
  );
}
