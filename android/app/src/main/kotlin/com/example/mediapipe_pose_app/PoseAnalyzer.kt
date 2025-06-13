package com.example.mediapipe_pose_app

import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker.PoseLandmarkerOptions
import com.google.mediapipe.framework.image.MPImage
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import androidx.camera.view.PreviewView


class PoseAnalyzer(
    private val context: Context,
    private val channel: MethodChannel,
    private val previewView: PreviewView
) {
    private lateinit var poseLandmarker: PoseLandmarker
    private val cameraExecutor = Executors.newSingleThreadExecutor()

    fun setup() {
        try {
            Log.d("PoseAnalyzer", "Inicializando modelo...")

            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("pose_landmarker_lite.task")
                .build()

            val options = PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setResultListener { result: PoseLandmarkerResult, _ ->
                    val landmarksText = result.landmarks().joinToString("\n") {
                        it.joinToString { l -> "(${l.x()}, ${l.y()})" }
                    }

                    // 🔐 INVOCAMOS el canal en el hilo principal
                    Handler(Looper.getMainLooper()).post {
                        channel.invokeMethod("onPoseResult", landmarksText)
                    }
                }
                .build()

            poseLandmarker = PoseLandmarker.createFromOptions(context, options)

            Log.d("PoseAnalyzer", "Modelo inicializado correctamente.")
            startCamera()

        } catch (e: Exception) {
            Log.e("PoseAnalyzer", "Error al inicializar el modelo", e)
        }
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)  // usamos la misma PreviewView
            }

            val imageAnalysis = ImageAnalysis.Builder()
                .setTargetResolution(Size(480, 640))
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()

            imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                processImageProxy(imageProxy)
            }

            val cameraSelector = CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                .build()

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    context as LifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
            } catch (exc: Exception) {
                Log.e("PoseAnalyzer", "Error al iniciar la cámara", exc)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun processImageProxy(imageProxy: ImageProxy) {
        try {
            val mediaImage = imageProxy.image
            if (mediaImage != null && ::poseLandmarker.isInitialized) {
                val rotation = imageProxy.imageInfo.rotationDegrees
                val mpImage: MPImage = MediaPipeImageUtils.imageToMPImage(mediaImage, rotation)
                poseLandmarker.detectAsync(mpImage, System.currentTimeMillis())
            }
        } catch (e: Exception) {
            Log.e("PoseAnalyzer", "Error procesando imagen", e)
        } finally {
            imageProxy.close()
        }
    }

    fun close() {
        if (::poseLandmarker.isInitialized) {
            poseLandmarker.close()
        }
        cameraExecutor.shutdown()
    }
}
