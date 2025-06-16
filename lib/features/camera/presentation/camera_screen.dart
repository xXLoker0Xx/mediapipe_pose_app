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
          // final widthRatio = _previewSize!.width / _inputWidth!;
          // final heightRatio = _previewSize!.height / _inputHeight!;

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

  /// Construye la interfaz de usuario de la pantalla de cámara
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final previewHeight = screenHeight * 0.6;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("🧘 Detección de Poses"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // 📸 Vista cámara + puntos (60%)
          // Utiliza Container para crear un borde alrededor de la vista de la cámara
          Container(
            key: _cameraContainerKey, // Clave para obtener tamaño
            width: screenWidth,
            height: previewHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.deepPurpleAccent,
                width: 3,
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
                            imputSize: Size(_inputWidth!.toDouble(), _inputHeight!.toDouble()),
                          ),
                          size: Size(screenWidth, previewHeight),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(), // o un contenedor vacío mientras llegan los datos
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
              child: ElevatedButton.icon(
                onPressed: _startPoseDetection,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Iniciar Detección"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // 📋 Resultados (30%)
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
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
