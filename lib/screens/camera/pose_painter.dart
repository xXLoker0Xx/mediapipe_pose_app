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
  final Size inputSize;

  // /// Datos del área de interés (opcional)
  final Map<String, dynamic>? areaData;

  PosePainter({
    required this.landmarks,
    required this.previewSize,
    required this.widgetSize,
    required this.inputSize,
    this.areaData,
  });

  @override
  void paint(Canvas canvas, Size widgetSize) {
    if (landmarks.isEmpty || previewSize == null) return;

    // debugPrint("📏 WidgetSize: $widgetSize");
    // debugPrint("📸 PreviewSize: $previewSize");
    // debugPrint("🧮 InputSize: $inputSize");

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    // final paintred = Paint()
    //   ..color = Colors.redAccent
    //   ..strokeWidth = 6
    //   ..style = PaintingStyle.fill;
    // Dibuja las áreas si las hay
    if (areaData != null) {
      final point = areaData!['point'];
      final List<dynamic> results = areaData!['results'] ?? [];

      final pointOffset = Offset(
        (point['x'] as double) * widgetSize.width,
        (point['y'] as double) * widgetSize.height,
      );

      for (final result in results) {
        final area = result['area'] as Map;
        final inside = result['inside'] as bool;

        final areaPaint = Paint()
          ..color = inside ? Colors.green.withAlpha(60) : Colors.red.withAlpha(60)
          ..style = PaintingStyle.fill;

        if (area['type'] == 'circle') {
          final center = Offset(
            (area['centerX'] as double) * widgetSize.width,
            (area['centerY'] as double) * widgetSize.height,
          );
          final radius = (area['radius'] as double) * widgetSize.width;
          canvas.drawCircle(center, radius, areaPaint);
        } else if (area['type'] == 'rectangle') {
          final rect = Rect.fromLTRB(
            (area['left'] as double) * widgetSize.width,
            (area['top'] as double) * widgetSize.height,
            (area['right'] as double) * widgetSize.width,
            (area['bottom'] as double) * widgetSize.height,
          );
          canvas.drawRect(rect, areaPaint);
        }
      }

      // Dibuja el punto evaluado
      final isInside = results.any((r) => r['inside'] == true);
      final paintPoint = Paint()
        ..color = isInside ? Colors.green : Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pointOffset, 10, paintPoint);
    }

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
