import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class NativeCameraPreview extends StatelessWidget {
  const NativeCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4, // Ajusta el aspecto según tu cámara
      child: PlatformViewLink(
        viewType: 'camera_preview_view',
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
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
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const platform = MethodChannel('pose_detector');
  String _poseResult = "Esperando datos...";

  @override
  void initState() {
    super.initState();
    _setUpChannelListener();
  }

  void _setUpChannelListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onPoseResult") {
        setState(() {
          _poseResult = call.arguments ?? "Sin datos";
        });
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
      appBar: AppBar(title: const Text('Cámara Nativa con Pose')),
      body: Column(
        children: [
          // Caja 1: Cámara
          const NativeCameraPreview(),

          // Caja 2: Botón
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: _startPoseDetection,
              child: const Text("Iniciar Detección"),
            ),
          ),

          // Caja 3: Resultado
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
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
    );
  }
}
