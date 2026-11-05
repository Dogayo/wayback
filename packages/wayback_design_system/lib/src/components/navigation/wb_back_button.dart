import 'package:flutter/material.dart';

class WbBackButton extends StatelessWidget {
  const WbBackButton({this.onPressed, this.platform, super.key});
  final VoidCallback? onPressed;
  final TargetPlatform? platform;
  @override
  Widget build(BuildContext context) {
    final currentPlatform = platform ?? Theme.of(context).platform;
    final apple =
        currentPlatform == TargetPlatform.iOS ||
        currentPlatform == TargetPlatform.macOS;
    return Semantics(
      button: true,
      label: 'Назад',
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        icon: Icon(
          apple ? Icons.arrow_back_ios_new : Icons.arrow_back,
          size: apple ? 20 : 24,
        ),
      ),
    );
  }
}
