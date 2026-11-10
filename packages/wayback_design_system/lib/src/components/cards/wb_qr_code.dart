import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/utils/qr_encoder.dart';

/// A QR code of [data]: for a phone camera to read off this screen.
///
/// Always black on white with its quiet zone, in the dark theme too, because
/// many scanners cannot read an inverted code. For the same reason these two
/// colors are not theme tokens.
class WbQrCode extends StatefulWidget {
  const WbQrCode({required this.data, this.semanticLabel, super.key});

  final String data;
  final String? semanticLabel;

  @override
  State<WbQrCode> createState() => _WbQrCodeState();
}

const double _maxSize = 285;
const int _quietModules = 4;
const Color _light = Color(0xFFFFFFFF);
const Color _dark = Color(0xFF000000);

class _WbQrCodeState extends State<WbQrCode> {
  // The screen behind a code rebuilds with every GPS fix.
  late QrMatrix _matrix = encodeQr(widget.data);

  @override
  void didUpdateWidget(WbQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _matrix = encodeQr(widget.data);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: widget.semanticLabel,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxSize),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: _light,
              borderRadius: WbRadius.large,
            ),
            child: CustomPaint(painter: _QrPainter(_matrix)),
          ),
        ),
      ),
    ),
  );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.matrix);

  final QrMatrix matrix;

  @override
  void paint(Canvas canvas, Size size) {
    final modules = matrix.size + 2 * _quietModules;
    // Whole pixels: modules that blur into each other scan worse.
    final ratio =
        WidgetsBinding
            .instance
            .platformDispatcher
            .implicitView
            ?.devicePixelRatio ??
        1;
    final module = (size.width / modules * ratio).floorToDouble() / ratio;
    final origin = (size.width - module * matrix.size) / 2;
    final paint = Paint()
      ..color = _dark
      ..isAntiAlias = false;
    for (var y = 0; y < matrix.size; y++) {
      for (var x = 0; x < matrix.size; x++) {
        if (matrix.modules[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(
              origin + x * module,
              origin + y * module,
              module,
              module,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) =>
      !identical(oldDelegate.matrix, matrix);
}
