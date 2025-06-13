import 'dart:ui';
import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<Offset> landmarks;

  PosePainter(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    for (final point in landmarks) {
      // Escala los puntos normalizados (0.0–1.0) al tamaño real del canvas
      final offset = Offset(point.dx * size.width, point.dy * size.height);
      canvas.drawCircle(offset, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
