import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/widgets/point_details_view.dart';
import 'package:wayback/features/points/view/widgets/points_error_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// One point: where and when, activity, navigation, rename, delete
/// (SCREENS.md §4.4).
///
/// Needs [PointDetailsBloc], [RenamePointBloc], [SetPointActiveBloc] and
/// [DeletePointBloc] above it.
class PointDetailsScreen extends StatelessWidget {
  const PointDetailsScreen({super.key});

  static void _showFailure(BuildContext context, Failure failure) =>
      WbSnackbar.show(context, context.l10n.error(failure.code).title);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PointDetailsBloc>().state;
    // While the point is being deleted, its disappearance is not an error.
    final leaving = context.watch<DeletePointBloc>().state.mapOrElse(
      inProgress: (_) => true,
      success: (_) => true,
      orElse: (_) => false,
    );
    return MultiBlocListener(
      listeners: [
        BlocListener<DeletePointBloc, ActionState<void>>(
          listener: (context, deleted) => deleted.mapOrNull(
            success: (_) {
              WbSnackbar.show(
                context,
                l10n.pointDeletedSnackbar(
                  state.dataOrNull?.point.name ?? l10n.pointDetailsTitle,
                ),
              );
              context.go(Routes.pointsList);
            },
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
        BlocListener<RenamePointBloc, ActionState<SavedPoint>>(
          listener: (context, renamed) => renamed.mapOrNull(
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
        BlocListener<SetPointActiveBloc, ActionState<SavedPoint>>(
          listener: (context, toggled) => toggled.mapOrNull(
            failure: (s) => _showFailure(context, s.failure),
          ),
        ),
      ],
      child: Scaffold(
        appBar: WbAppBar(
          title: state.dataOrNull?.point.name ?? l10n.pointDetailsTitle,
          onBack: context.back,
        ),
        body: leaving
            ? const _Loading()
            : state.map(
                initial: (_) => const _Loading(),
                loading: (s) => switch (s.previous) {
                  final point? => PointDetailsView(point),
                  null => const _Loading(),
                },
                success: (s) => PointDetailsView(s.data),
                failure: (s) => PointsErrorView(
                  failure: s.failure,
                  actionLabel: l10n.pointBackToList,
                  onAction: () => context.go(Routes.pointsList),
                ),
              ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(WbSpacing.screenPadding),
    child: Column(
      spacing: WbSpacing.sm,
      children: [
        WbPointCardSkeleton(),
        WbSkeleton(height: WbSpacing.xxxxxl),
      ],
    ),
  );
}
