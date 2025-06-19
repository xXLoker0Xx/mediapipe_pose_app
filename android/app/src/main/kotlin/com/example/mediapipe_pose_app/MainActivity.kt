package com.example.mediapipe_pose_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import androidx.camera.view.PreviewView

// Esta clase representa la actividad principal de la aplicación Flutter.
class MainActivity : FlutterFragmentActivity() {
    // Inicializa el analizador de poses y la fábrica de vistas de cámara.
    private lateinit var poseAnalyzer: PoseAnalyzer
    private lateinit var previewFactory: CameraPreviewFactory

    // Este método se llama cuando la actividad se crea por primera vez.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Llama al método de la superclase para configurar el motor de Flutter.
        // Aquí se inicializan los componentes necesarios para la detección de poses y la vista previa de la cámara.
        super.configureFlutterEngine(flutterEngine)
        // Obtiene el mensajero de Dart para la comunicación entre Flutter y Android.
        // Este mensajero se utiliza para enviar mensajes entre Flutter y el código nativo de Android.
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1️⃣ Registra la vista de la cámara nativa
        previewFactory = CameraPreviewFactory(messenger, this, this)
        // Registra la fábrica de vistas de cámara con el motor de Flutter.
        // Esto permite que Flutter cree instancias de CameraPreviewView cuando se solicite.
        // La fábrica de vistas se utiliza para crear una vista previa de la cámara que se mostrará en la aplicación Flutter.
        // La vista previa de la cámara se mostrará en la aplicación Flutter utilizando CameraPreviewView.
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("camera_preview_view", previewFactory)

        // 2️⃣ Canal para comunicación nativa
        val channel = MethodChannel(messenger, "pose_detector")

        // 3️⃣ Escucha método de Flutter para iniciar detección
        channel.setMethodCallHandler { call, result ->
            // Este método se llama cuando Flutter invoca un método en el canal "pose_detector".
            // Aquí se maneja la llamada desde Flutter para iniciar la detección de poses.
            if (call.method == "startPoseDetection") {
                // Verifica si el método llamado es "startPoseDetection".
                // Si es así, inicializa el analizador de poses y la vista previa de la cámara.
                val previewView: PreviewView? = previewFactory.lastCreatedView?.previewView
                // Obtiene la vista previa de la cámara desde la última vista creada por la fábrica.
                // Si la vista previa de la cámara está disponible, inicializa el analizador de poses.
                if (previewView != null) {
                    // Inicializa el analizador de poses con el contexto, el canal y la vista previa.
                    // El analizador de poses se encargará de procesar las imágenes de la cámara y detectar poses en tiempo real.
                    poseAnalyzer = PoseAnalyzer(this, channel, previewView)
                    // Configura el analizador de poses.
                    poseAnalyzer.setup()
                    result.success("Pose detection started")
                } else {
                    result.error("preview_unavailable", "No se pudo obtener PreviewView", null)
                }

            // ✅ Nuevo método para cerrar manualmente
            } else if (call.method == "stopPoseDetection") {
                if (::poseAnalyzer.isInitialized) {
                    poseAnalyzer.close()
                    result.success("Pose detection stopped")
                } else {
                    result.error("not_initialized", "PoseAnalyzer no está inicializado", null)
                }

            // Sino el método no está implementado
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::poseAnalyzer.isInitialized) {
            poseAnalyzer.close()
        }
    }
}
