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
    // Contexto de la aplicación, necesario para inicializar el modelo y la cámara
    private val context: Context,
    // Canal de comunicación con Flutter, para enviar los resultados de la detección
    private val channel: MethodChannel,
    // Vista previa de la cámara, donde se mostrará el video en tiempo real
    private val previewView: PreviewView,

) {
    // Inicializamos PoseLandmarker, que es el modelo de detección de poses
    private lateinit var poseLandmarker: PoseLandmarker
    // Executor para manejar el análisis de imágenes en un hilo separado
    private val cameraExecutor = Executors.newSingleThreadExecutor()

    // Variables para almacenar el tamaño de la imagen de entrada
    private var inputWidth = 0
    private var inputHeight = 0

    fun setup() {
        try {
            Log.d("PoseAnalyzer", "Inicializando modelo...")

            // Configuración de opciones del modelo
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("pose_landmarker_lite.task")
                .build()

            // Configuración de PoseLandmarker
            // Usamos RunningMode.LIVE_STREAM para análisis en tiempo real
            // y configuramos un listener para recibir los resultados
            // que se enviarán a Flutter
            // El listener se ejecuta en el hilo principal para evitar problemas de concurrencia
            val options = PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setResultListener { result: PoseLandmarkerResult, _ ->
                    // Extraemos los puntos de referencia de la pose detectada
                    val landmarks = result.landmarks().firstOrNull()
                    // Convertimos los puntos de referencia a un formato que Flutter pueda entender

                    val landmarkData = landmarks?.map { mapOf("x" to it.x(), "y" to it.y()) }

                    val dataToSend = mapOf(
                        "landmarks" to landmarkData,
                        "inputWidth" to inputWidth,
                        "inputHeight" to inputHeight
                    )

                    Handler(Looper.getMainLooper()).post {
                        Log.d("POSE_DEBUG", "➡️ Enviando ${landmarkData?.size ?: 0} puntos con tamaño $inputWidth x $inputHeight a Flutter")
                        channel.invokeMethod("posePoints", dataToSend)
                    }
                }
                .build()

            // Creamos el PoseLandmarker con las opciones configuradas
            // Usamos createFromOptions para inicializarlo con las opciones
            poseLandmarker = PoseLandmarker.createFromOptions(context, options)

            // Verificamos que el modelo se haya inicializado correctamente
            Log.d("PoseAnalyzer", "Modelo inicializado correctamente.")

            // Iniciamos la cámara para comenzar a recibir imágenes
            startCamera()

            // Enviar tamaño del preview real a Flutter cuando esté listo
            previewView.post {
                val width = previewView.width
                val height = previewView.height

                Log.d("POSE_DEBUG", "📏 PreviewView visible: ${width}x$height")

                val previewSize = mapOf("width" to width, "height" to height)
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("onPreviewSize", previewSize)
                }
            }

        } catch (e: Exception) {
            Log.e("PoseAnalyzer", "Error al inicializar el modelo", e)
        }
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun startCamera() {
        // Obtenemos el ProcessCameraProvider para gestionar la cámara
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        // Añadimos un listener para esperar a que el proveedor de cámara esté listo
        // Usamos ContextCompat.getMainExecutor para asegurarnos de que se ejecute en el hilo principal
        cameraProviderFuture.addListener({
            // Una vez que el proveedor de cámara está listo, lo obtenemos
            val cameraProvider = cameraProviderFuture.get()

            // Configuramos la vista previa de la cámara
            // Usamos Preview.Builder para crear una vista previa
            val preview = Preview.Builder().build().also {
                // Configuramos la vista previa para que use la PreviewView proporcionada
                it.setSurfaceProvider(previewView.surfaceProvider)  // usamos la misma PreviewView
            }

            // Configuramos el análisis de imágenes
            // Usamos ImageAnalysis.Builder para crear un analizador de imágenes
            val imageAnalysis = ImageAnalysis.Builder()
                // Configuramos el tamaño de la resolución de destino
                // .setTargetResolution(Size(480, 640))
                // Configuramos el modo de análisis para mantener solo la última imagen
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                // Configuramos el análisis para que use un executor específico
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                .build()

            // Configuramos el analizador de imágenes
            // Usamos un lambda para procesar cada ImageProxy que se recibe
            imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                // Procesamos la imagen recibida
                // Llamamos a processImageProxy para convertir la imagen y pasarla al PoseLandmarker
                processImageProxy(imageProxy)
            }

            // Configuramos el selector de cámara para usar la cámara frontal
            // Usamos CameraSelector.Builder para crear un selector de cámara
            val cameraSelector = CameraSelector.Builder()
                // Especificamos que queremos usar la cámara frontal
                .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                .build()

            // Intentamos vincular la cámara al ciclo de vida de la aplicación
            // Usamos bindToLifecycle para vincular la cámara al ciclo de vida del contexto
            // Esto asegura que la cámara se inicie y detenga automáticamente según el ciclo de vida de la actividad
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

    // Variable para almacenar el tiempo del último análisis
    private var lastAnalysisTime = 0L

    // Procesa cada ImageProxy recibido del análisis de imágenes
    private fun processImageProxy(imageProxy: ImageProxy) {
        // Intentamos obtener la imagen del ImageProxy
        // Si la imagen es nula o el PoseLandmarker no está inicializado, cerramos el ImageProxy
        try {
            // Verificamos si el PoseLandmarker está inicializado y si la imagen es válida
            val currentTime = System.currentTimeMillis()
            // Si el PoseLandmarker no está inicializado, cerramos el ImageProxy
            if (currentTime - lastAnalysisTime < 75) {
                // Si el tiempo desde el último análisis es menor a 75ms, cerramos el ImageProxy
                imageProxy.close() // ⛔ Saltar análisis si fue hace <75ms
                return
            }

            // Verificamos que la imagen no sea nula y que el PoseLandmarker esté inicializado
            val mediaImage = imageProxy.image
            // Si la imagen es nula, cerramos el ImageProxy y salimos
            if (mediaImage != null && ::poseLandmarker.isInitialized) {
                // Convertimos la imagen a MPImage, que es el formato que MediaPipe usa para procesar imágenes
                // Obtenemos la rotación de la imagen para ajustarla correctamente
                // MediaPipe espera que las imágenes estén en formato NV21, así que convertimos la imagen
                val rotation = imageProxy.imageInfo.rotationDegrees
                // Convertimos la imagen a MPImage usando MediaPipeImageUtils
                // Esta función convierte la imagen YUV a NV21 y luego a un bitmap que MediaPipe puede procesar
                val mpImage: MPImage = MediaPipeImageUtils.imageToMPImage(mediaImage, rotation)
                inputWidth = mpImage.width
                inputHeight = mpImage.height
                // Llamamos al PoseLandmarker para detectar la pose en la imagen
                // Usamos detectAsync para procesar la imagen de forma asíncrona
                // Pasamos la imagen y el timestamp actual para que MediaPipe pueda sincronizar los resultados
                // poseLandmarker.detectAsync(mpImage, System.currentTimeMillis())
                poseLandmarker.detectAsync(mpImage, currentTime)
                // Actualizamos el tiempo del último análisis
                lastAnalysisTime = currentTime
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