package com.example.mediapipe_pose_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import androidx.camera.view.PreviewView

class MainActivity : FlutterActivity() {
    private lateinit var poseAnalyzer: PoseAnalyzer
    private lateinit var previewFactory: CameraPreviewFactory

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1️⃣ Registra la vista de la cámara nativa
        previewFactory = CameraPreviewFactory(messenger, this, this)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("camera_preview_view", previewFactory)

        // 2️⃣ Canal para comunicación nativa
        val channel = MethodChannel(messenger, "pose_detector")

        // 3️⃣ Escucha método de Flutter para iniciar detección
        channel.setMethodCallHandler { call, result ->
            if (call.method == "startPoseDetection") {
                val previewView: PreviewView? = previewFactory.lastCreatedView?.previewView

                if (previewView != null) {
                    poseAnalyzer = PoseAnalyzer(this, channel, previewView)
                    poseAnalyzer.setup()
                    result.success("Pose detection started")
                } else {
                    result.error("preview_unavailable", "No se pudo obtener PreviewView", null)
                }
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
