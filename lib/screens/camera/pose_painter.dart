import 'package:flutter/material.dart';

/// CustomPainter para dibujar los puntos de la pose detectada
class PosePainter extends CustomPainter {
  /// Lista de puntos ya escalados desde CameraScreen
  final List<Offset> landmarks;

  /// Tamaño real del preview de cámara en píxeles (no del widget)
  final Size? previewSize;

  /// Tamaño del widget de Flutter
  final Size widgetSize;

  /// Tamaño real de la imagen procesada
  final Size imputSize;

  PosePainter({
    required this.landmarks,
    required this.previewSize,
    required this.widgetSize,
    required this.imputSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || previewSize == null) return;

    // debugPrint("📏 WidgetSize: $widgetSize");
    // debugPrint("📸 PreviewSize: $previewSize");
    // debugPrint("🧮 InputSize: $imputSize");

    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    // final paintred = Paint()
    //   ..color = Colors.redAccent
    //   ..strokeWidth = 6
    //   ..style = PaintingStyle.fill;

    for (int i = 0; i < landmarks.length; i++) {
      final point = landmarks[i];

      final xNorm = point.dx;
      final yNorm = point.dy;

      final xwidget = xNorm * widgetSize.width;
      final ywidget = yNorm * widgetSize.height;

      final xFinal = widgetSize.width - xwidget;

      // debugPrint('🧠 Point $i');
      // debugPrint('  ↪ Normalizado: (${xNorm.toStringAsFixed(3)}, ${yNorm.toStringAsFixed(3)})');
      // debugPrint('  ↪ InputPos: (${xInput.toStringAsFixed(1)}, ${yInput.toStringAsFixed(1)})');
      // debugPrint('  ↪ ScaledPos: (${xScaled.toStringAsFixed(1)}, ${yScaled.toStringAsFixed(1)})');
      // debugPrint('  ↪ Final pintado (mirrored): (${xFinal.toStringAsFixed(1)}, ${yScaled.toStringAsFixed(1)})');
      
      canvas.drawCircle(Offset(xFinal, ywidget), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) =>
      oldDelegate.landmarks != landmarks || oldDelegate.previewSize != previewSize;
}
