import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/feedback/wb_skeleton.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

const double _dialSize = 56;

/// Active point on Home: direction preview, name with its type and distance.
///
/// [rotation] is the arrow angle in degrees (bearing minus heading); `null`
/// hides the arrow while the direction is not known yet.
class WbPointCard extends StatelessWidget {
  const WbPointCard({
    required this.title,
    required this.distance,
    required this.typeIcon,
    this.rotation,
    this.onTap,
    super.key,
  });
  final String title;
  final String distance;
  final IconData typeIcon;
  final double? rotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: '$title, $distance',
    excludeSemantics: true,
    child: _PointCardFrame(
      onTap: onTap,
      dial: rotation == null
          ? null
          : Transform.rotate(
              angle: rotation! * math.pi / 180,
              child: Icon(
                Icons.navigation,
                size: WbIconSize.xl,
                color: context.wbColors.brand600,
              ),
            ),
      body: Column(
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
      trailing: Icon(
        Icons.chevron_right,
        color: context.wbColors.contentTertiary,
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
  });
  final Widget body;
  final Widget? dial;
  final bool dialFilled;
  final Widget? trailing;
  final VoidCallback? onTap;

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
