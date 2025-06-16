import 'package:flutter/material.dart';

/// CustomPainter para dibujar los puntos de la pose detectada
class PosePainter extends CustomPainter {
  /// Lista de puntos ya escalados desde CameraScreen
  final List<Offset> landmarks;

  /// Tamaño real del preview de cámara en píxeles (no del widget)
  final Size? previewSize;

  /// Tamaño del widget de Flutter
  final Size widgetSize;

  PosePainter({
    required this.landmarks,
    required this.previewSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || previewSize == null) return;

    debugPrint("📏 WidgetSize: $widgetSize");
    debugPrint("📸 PreviewSize: $previewSize");


    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    for (final point in landmarks) {
      // Escalamos al tamaño del widget y aplicamos el espejo horizontal
      final double x = point.dx * widgetSize.width;
      final double y = point.dy * widgetSize.height;
      final double mirroredX = widgetSize.width - x;

      canvas.drawCircle(Offset(mirroredX, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) =>
      oldDelegate.landmarks != landmarks || oldDelegate.previewSize != previewSize;
}
