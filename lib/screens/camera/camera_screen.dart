// 📁 lib/screens/shared/camera_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'pose_painter.dart';

// Pantalla principal de la cámara con detección de poses
class CameraScreen extends StatefulWidget {
  /// Constructor de la pantalla de cámara
  /// Utiliza [super.key] para permitir el uso de claves en widgets
  /// para optimizar el rendimiento y la reconstrucción de widgets.
  const CameraScreen({super.key});

  /// Método estático para crear una instancia de [CameraScreen]
  @override
  // Crea el estado asociado a esta pantalla
  // Utiliza un State<CameraScreen> para manejar el estado de la pantalla
  // Esto permite que la pantalla tenga un estado mutable
  State<CameraScreen> createState() => _CameraScreenState();
}

// Estado asociado a la pantalla de cámara
class _CameraScreenState extends State<CameraScreen> {
  /// Canal de método para comunicarse con la plataforma nativa
  /// Utiliza un MethodChannel para invocar métodos nativos
  static const platform = MethodChannel('pose_detector');

  /// Datos de verificación del área
  Map<String, dynamic>? _areaCheckData;

  /// Lista de puntos de la pose detectada
  /// Utiliza una lista de Offset para almacenar las coordenadas de los puntos
  List<Offset> _landmarks = [];

  /// Resultado de la detección de poses
  /// Utiliza una cadena para mostrar el resultado de la detección
  String _poseResult = "Esperando datos...";

  /// Clave global para obtener el tamaño del contenedor de la vista de la cámara
  final GlobalKey _cameraContainerKey = GlobalKey();

  // Tamaño real del preview de cámara recibido desde Android
  Size? _previewSize;
  int? _inputWidth;
  int? _inputHeight;

  /// Método de inicialización del estado
  /// Se llama una vez cuando el estado se crea por primera vez
  @override
  void initState() {
    // Llama al método initState del superclase para asegurar la inicialización correcta
    // Configura el listener del canal de método para recibir actualizaciones de la plataforma nativa
    super.initState();
    _setUpChannelListener();
  }

  /// Método para configurar el listener del canal de método
  /// Escucha los métodos invocados desde la plataforma nativa
  void _setUpChannelListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "posePoints") {
        final Map<dynamic, dynamic> data = call.arguments;

        final List<dynamic> rawPoints = data['landmarks'] ?? [];
        _inputWidth = data['inputWidth'];
        _inputHeight = data['inputHeight'];

        if (_previewSize != null && _inputWidth != null && _inputHeight != null) {
          final puntos = rawPoints.map<Offset>((e) {
            final x = (e['x'] as double);
            final y = (e['y'] as double);
            return Offset(x, y);
          }).toList();

          setState(() {
            _landmarks = puntos;
          });
        }
      }

      if (call.method == "onPreviewSize") {
        final Map previewSize = call.arguments;
        final double width = (previewSize['width'] as int).toDouble();
        final double height = (previewSize['height'] as int).toDouble();

        setState(() {
          _previewSize = Size(width, height);
        });
      }

      if (call.method == "onAreaCheck") {
        final Map<dynamic, dynamic> rawData = call.arguments;
        final Map<String, dynamic> converted = Map<String, dynamic>.from(rawData);
        setState(() {
          _areaCheckData = converted;
        });
      }
    });
  }

  /// Método para iniciar la detección de poses
  /// Invoca el método nativo "startPoseDetection" para iniciar la detección de poses
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

  Future<void> _stopPoseDetection() async {
    try {
      await platform.invokeMethod('stopPoseDetection');
      setState(() {
        _poseResult = "Detección detenida.";
        _landmarks.clear();
      });
    } catch (e) {
      setState(() {
        _poseResult = "Error al detener detección: $e";
      });
    }
  }

  /// Construye la interfaz de usuario de la pantalla de cámara
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final previewHeight = screenHeight * 0.637;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("🧘 Detección de Poses"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 📸 Vista cámara + puntos (60%)
          Container(
            key: _cameraContainerKey,
            width: screenWidth,
            height: previewHeight,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: screenWidth,
                height: previewHeight,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
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
                    ),
                    if (_landmarks.isNotEmpty &&
                        _previewSize != null &&
                        _inputWidth != null &&
                        _inputHeight != null) ...[
                      IgnorePointer(
                        child: CustomPaint(
                          painter: PosePainter(
                            landmarks: _landmarks,
                            previewSize: _previewSize,
                            widgetSize: Size(screenWidth, previewHeight),
                            inputSize: Size(_inputWidth!.toDouble(), _inputHeight!.toDouble()),
                            areaData: _areaCheckData,
                          ),
                          size: Size(screenWidth, previewHeight),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(),
                    ]
                  ],
                ),
              ),
            ),
          ),

          // 🟪 Botón (10%)
          SizedBox(
            height: screenHeight * 0.1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startPoseDetection,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Iniciar"),
                  ),
                  const SizedBox(width: 16), // Espacio entre botones
                  ElevatedButton.icon(
                    onPressed: _stopPoseDetection,
                    icon: const Icon(Icons.stop),
                    label: const Text("Detener"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shadowColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),


          // 📋 Resultados (30%)
          // Expanded(
          //   child: Container(
          //     width: double.infinity,
          //     margin: const EdgeInsets.symmetric(horizontal: 16),
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).colorScheme.surface,
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: SingleChildScrollView(
          //       child: Text(
          //         _poseResult,
          //         style: Theme.of(context).textTheme.bodyMedium,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
} 
