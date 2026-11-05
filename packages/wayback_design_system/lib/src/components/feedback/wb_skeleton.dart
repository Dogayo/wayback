import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbSkeleton extends StatefulWidget {
  const WbSkeleton({this.width = double.infinity, this.height = 12, super.key});
  final double width;
  final double height;
  @override
  State<WbSkeleton> createState() => _WbSkeletonState();
}

class _WbSkeletonState extends State<WbSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WbMotion.shimmer,
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: FadeTransition(
      opacity: Tween(begin: .35, end: .75).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: context.wbColors.contentDisabled,
          borderRadius: WbRadius.small,
        ),
      ),
    ),
  );
}
