import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Dial content of a point card: the arrow to [pointId], or [icon] without a
/// direction. Only this widget rebuilds on compass readings, not the list.
class PointDirection extends StatelessWidget {
  const PointDirection(this.pointId, {required this.icon, super.key});

  final String pointId;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PointDirectionsBloc,
        DataState<PointDirections>,
        (double?, bool)
      >(
        selector: (state) {
          final directions = state.dataOrNull;
          return (
            directions?.arrows[pointId],
            directions?.compass == CompassStatus.unreliable,
          );
        },
        builder: (context, direction) {
          final (rotation, unreliable) = direction;
          final approximate = rotation != null && unreliable;
          return WbPointDirection(
            icon: icon,
            rotation: rotation,
            tone: approximate ? WbDirectionTone.unreliable : WbDirectionTone.ok,
            semanticLabel: approximate
                ? context.l10n.pointDirectionApproximate
                : null,
          );
        },
      );
}
