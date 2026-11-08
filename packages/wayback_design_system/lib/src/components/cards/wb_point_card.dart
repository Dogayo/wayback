import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/feedback/wb_skeleton.dart';
import 'package:wayback_design_system/src/components/wayfinding/wb_direction_dial.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

const double _dialSize = 56;

/// Content of the [WbPointCard] dial: an arrow, or [icon] of the point type
/// while the direction is not known.
///
/// [rotation] is the arrow angle in degrees (bearing minus heading), not
/// wrapped. [semanticLabel] is read after the card's own label.
class WbPointDirection extends StatelessWidget {
  const WbPointDirection({
    required this.icon,
    this.rotation,
    this.tone = WbDirectionTone.ok,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final double? rotation;
  final WbDirectionTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    return Semantics(
      label: semanticLabel,
      child: switch (rotation) {
        final angle? => WbDirectionArrow(
          rotation: angle,
          color: switch (tone) {
            WbDirectionTone.ok => colors.brand600,
            WbDirectionTone.unreliable => colors.warning,
          },
          size: WbIconSize.xl,
        ),
        null => Icon(icon, size: WbIconSize.lg, color: colors.contentSecondary),
      },
    );
  }
}

/// Active point on Home: direction preview, name with its type and distance.
///
/// [direction] fills the dial, usually a [WbPointDirection]; without it the
/// dial shows [typeIcon].
class WbPointCard extends StatelessWidget {
  const WbPointCard({
    required this.title,
    required this.distance,
    required this.typeIcon,
    this.direction,
    this.onTap,
    this.onLongPress,
    super.key,
  });
  final String title;
  final String distance;
  final IconData typeIcon;
  final Widget? direction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      button: onTap != null,
      label: '$title, $distance',
      child: _PointCardFrame(
        onTap: onTap,
        onLongPress: onLongPress,
        dial: direction ?? WbPointDirection(icon: typeIcon),
        body: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    typeIcon,
                    size: WbIconSize.sm,
                    color: context.wbColors.contentSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      style: context.wbText.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(distance, style: context.wbText.headlineSmall),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.wbColors.contentTertiary,
        ),
      ),
    ),
  );
}

/// Loading placeholder with the same frame as [WbPointCard].
class WbPointCardSkeleton extends StatelessWidget {
  const WbPointCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const _PointCardFrame(
    dial: ClipOval(
      child: WbSkeleton(width: _dialSize, height: _dialSize),
    ),
    dialFilled: false,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WbSkeleton(width: 96, height: 16),
        SizedBox(height: 10),
        WbSkeleton(width: 72, height: 24),
      ],
    ),
  );
}

class _PointCardFrame extends StatelessWidget {
  const _PointCardFrame({
    required this.body,
    this.dial,
    this.dialFilled = true,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });
  final Widget body;
  final Widget? dial;
  final bool dialFilled;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => Material(
    color: context.wbColors.surfaceElevated,
    shape: RoundedRectangleBorder(
      borderRadius: WbRadius.medium,
      side: BorderSide(color: context.wbColors.borderSubtle),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(WbSpacing.md),
        child: Row(
          children: [
            Container(
              width: _dialSize,
              height: _dialSize,
              alignment: Alignment.center,
              decoration: dialFilled
                  ? BoxDecoration(
                      color: context.wbColors.surfaceContainer,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: dial,
            ),
            const SizedBox(width: WbSpacing.md),
            Expanded(child: body),
            if (trailing != null) ...[
              const SizedBox(width: WbSpacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    ),
  );
}
