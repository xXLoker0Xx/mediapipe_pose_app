import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'pose_painter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const platform = MethodChannel('pose_detector');

  List<Offset> _landmarks = [];
  String _poseResult = "Esperando datos...";

  @override
  void initState() {
    super.initState();
    _setUpChannelListener();
  }

  void _setUpChannelListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onPoseResult") {
        final raw = call.arguments as String?;
        if (raw != null) {
          final points = raw
              .split("\n")
              .map((line) {
                final match = RegExp(r"\(([^,]+), ([^)]+)\)").firstMatch(line);
                if (match != null) {
                  final x = double.tryParse(match.group(1)!);
                  final y = double.tryParse(match.group(2)!);
                  if (x != null && y != null) return Offset(x, y);
                }
                return null;
              })
              .whereType<Offset>()
              .toList();
          setState(() {
            _landmarks = points;
            _poseResult = raw;
          });
        }
      }
    });
  }

  Future<void> _startPoseDetection() async {
    try {
      final result = await platform.invokeMethod('startPoseDetection');
      setState(() {
        _poseResult = result;
      });
    } catch (e) {
      setState(() {
        _poseResult = "Error al iniciar detección: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pose Detection")),
      body: SafeArea(
        child: Column(
          children: [
            // CÁMARA + OVERLAY
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlatformViewLink(
                    viewType: 'camera_preview_view',
                    surfaceFactory: (context, controller) {
                      return AndroidViewSurface(
                        controller: controller as AndroidViewController,
                        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                        hitTestBehavior: PlatformViewHitTestBehavior.translucent,
                      );
                    },
                    onCreatePlatformView: (params) {
                      return PlatformViewsService.initSurfaceAndroidView(
                        id: params.id,
                        viewType: 'camera_preview_view',
                        layoutDirection: TextDirection.ltr,
                        creationParams: null,
                        creationParamsCodec: const StandardMessageCodec(),
                      )
                        ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                        ..create();
                    },
                  ),

                  // Overlay de puntos escalados
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: PosePainter(_landmarks),
                      ),
                    ),
                  ),
                ],
              ),
            ),



            // BOTÓN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: _startPoseDetection,
                child: const Text("Iniciar Detección"),
              ),
            ),

            // TEXTO DE RESULTADO
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: SingleChildScrollView(
                  child: Text(
                    _poseResult,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
