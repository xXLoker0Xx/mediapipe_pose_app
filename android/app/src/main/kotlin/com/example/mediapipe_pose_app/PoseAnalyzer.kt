package com.example.mediapipe_pose_app

import android.content.Context
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class PoseAnalyzer(
    private val context: Context,
    private val channel: MethodChannel
) {
    private lateinit var poseLandmarker: PoseLandmarker

    fun setup() {
        try {
            Log.d("PoseAnalyzer", "Inicializando modelo...")

            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("pose_landmarker_lite.task")
                .build()

            val options = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setResultListener { result: PoseLandmarkerResult, inputImage -> 
                    Log.d("PoseAnalyzer", "Resultado recibido: ${result.landmarks()}")
                }


                .build()

            // Inicializar PoseLandmarker con las opciones configuradas
            poseLandmarker = PoseLandmarker.createFromOptions(context, options)

            Log.d("PoseAnalyzer", "Modelo inicializado correctamente.")
        } catch (e: Exception) {
            Log.e("PoseAnalyzer", "Error al inicializar el modelo", e)
        }
    }

    fun close() {
        // Asegurarse de que poseLandmarker esté inicializado antes de cerrarlo
        if (::poseLandmarker.isInitialized) {
            poseLandmarker.close()
        }
    }
}
