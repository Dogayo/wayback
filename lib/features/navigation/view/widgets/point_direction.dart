import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Dial content of a point card: the arrow to [pointId], or [icon] without a
/// direction. Only this widget rebuilds on compass readings, not the list.
///
/// [large] is the full dial with its beam, for a point alone on Home.
class PointDirection extends StatelessWidget {
  const PointDirection(
    this.pointId, {
    required this.icon,
    this.large = false,
    super.key,
  });

  final String pointId;
  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PointDirectionsBloc,
        DataState<PointDirections>,
        (double?, bool, double?)
      >(
        selector: (state) {
          final directions = state.dataOrNull;
          return (
            directions?.arrows[pointId],
            directions?.compass == CompassStatus.unreliable,
            directions?.compassAccuracyDegrees,
          );
        },
        builder: (context, direction) {
          final (rotation, unreliable, spread) = direction;
          final approximate = rotation != null && unreliable;
          final tone = approximate
              ? WbDirectionTone.unreliable
              : WbDirectionTone.ok;
          final label = context.l10n.pointDirectionApproximate;
          if (large) return _dial(rotation, spread, tone, label, approximate);
          return WbPointDirection(
            icon: icon,
            rotation: rotation,
            tone: tone,
            semanticLabel: approximate ? label : null,
          );
        },
      );

  /// The card reads out the point; only an approximate direction adds to it.
  Widget _dial(
    double? rotation,
    double? spread,
    WbDirectionTone tone,
    String label,
    bool approximate,
  ) => Semantics(
    label: approximate ? label : null,
    child: ExcludeSemantics(
      child: switch (rotation) {
        final angle? => WbDirectionDial(
          rotation: angle,
          spread: spread ?? WbDirectionDial.maxSpread,
          tone: tone,
          semanticLabel: label,
          size: WbPointHeroCard.dialSize,
        ),
        null => WbDirectionIcon(icon, size: WbPointHeroCard.dialSize),
      },
    ),
  );
}
