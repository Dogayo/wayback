import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/features/onboarding/view/bloc/finish_onboarding_bloc.dart';
import 'package:wayback/features/onboarding/view/widgets/onboarding_how_list.dart';
import 'package:wayback/features/onboarding/view/widgets/onboarding_step.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// First-launch onboarding: what the app is for, how it works and why it
/// needs location (SCREENS.md §4.0).
///
/// Needs [FinishOnboardingBloc] above it.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.next, super.key});

  /// Where to go when done instead of Home, e.g. a point someone sent.
  final String? next;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = 3;
  static const _last = _steps - 1;

  late final PageController _pages;
  var _page = 0;

  @override
  void initState() {
    super.initState();
    _pages = PageController();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final duration = WbMotion.of(context, WbMotion.slow);
    if (duration == Duration.zero) return _pages.jumpToPage(page);
    _pages.animateToPage(page, duration: duration, curve: WbMotion.easeOut);
  }

  /// Onward whatever the outcome: a failed save must not trap the user.
  void _onFinished(BuildContext context, ActionState<void> state) =>
      state.mapOrNull(
        success: (_) => context.go(widget.next ?? Routes.home),
        failure: (_) => context.go(widget.next ?? Routes.home),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final finishing = context.watch<FinishOnboardingBloc>().state.isInProgress;
    final finish = context.read<FinishOnboardingBloc>().run;
    final onLast = _page == _last;
    return BlocListener<FinishOnboardingBloc, ActionState<void>>(
      listener: _onFinished,
      // System back steps through the pages; from the first it leaves.
      child: PopScope(
        canPop: _page == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goTo(_page - 1);
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Visibility.maintain(
                    visible: !onLast,
                    child: WbButton(
                      label: l10n.onboardingSkip,
                      variant: WbButtonVariant.tertiary,
                      onPressed: onLast ? null : () => _goTo(_last),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (page) => setState(() => _page = page),
                    children: [
                      OnboardingStep(
                        illustration: WbIllustrationKind.compassRose,
                        title: l10n.onboardingIntroTitle,
                        body: l10n.onboardingIntroBody,
                      ),
                      OnboardingStep(
                        illustration: WbIllustrationKind.trail,
                        title: l10n.onboardingHowTitle,
                        content: OnboardingHowList(
                          steps: [
                            l10n.onboardingHowSave,
                            l10n.onboardingHowLeave,
                            l10n.onboardingHowReturn,
                          ],
                          note: l10n.onboardingHowOffline,
                        ),
                      ),
                      OnboardingStep(
                        illustration: WbIllustrationKind.location,
                        title: l10n.onboardingLocationTitle,
                        body: l10n.onboardingLocationBody,
                      ),
                    ],
                  ),
                ),
                WbPageDots(
                  count: _steps,
                  index: _page,
                  semanticLabel: l10n.onboardingProgress(_page + 1, _steps),
                ),
                Padding(
                  padding: const EdgeInsets.all(WbSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: WbSpacing.xs,
                    children: [
                      if (!onLast)
                        WbButton(
                          label: l10n.onboardingNext,
                          onPressed: () => _goTo(_page + 1),
                        )
                      else ...[
                        WbButton(
                          label: l10n.onboardingLocationAllow,
                          loading: finishing,
                          onPressed: () => finish(true),
                        ),
                        WbButton(
                          label: l10n.onboardingLocationLater,
                          variant: WbButtonVariant.tertiary,
                          onPressed: finishing ? null : () => finish(false),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
