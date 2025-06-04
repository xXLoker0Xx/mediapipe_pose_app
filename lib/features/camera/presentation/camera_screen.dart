import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];

  static const platform = MethodChannel('pose_detector');
  String _poseResult = "Esperando datos...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setUpChannelListener();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();

    // Buscar la cámara frontal
    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();

    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
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
      // Llamamos al método nativo
      final result = await platform.invokeMethod('startPoseDetection');
      
      // Si la invocación es exitosa, el resultado será el mensaje de éxito
      setState(() {
        _poseResult = result;  // Actualiza el resultado con el mensaje de éxito
      });
    } catch (e) {
      // Si ocurre un error, lo capturamos y mostramos el mensaje de error
      setState(() {
        _poseResult = "Error al iniciar detección: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista en Vivo')),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  top: 20,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: _startPoseDetection,
                    child: const Text("Iniciar Detección"),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      _poseResult,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
