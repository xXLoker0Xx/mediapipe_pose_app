package com.example.mediapipe_pose_app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.StandardMessageCodec

// Esta clase es una fábrica de vistas que crea instancias de CameraPreviewView.
class CameraPreviewFactory(
    // Mensajero binario para la comunicación entre Flutter y Android.
    private val messenger: BinaryMessenger,
    // Contexto de la aplicación, necesario para crear vistas.
    private val context: Context,
    // Propietario del ciclo de vida, necesario para manejar el ciclo de vida de la vista.
    private val lifecycleOwner: LifecycleOwner
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    // Última vista creada por esta fábrica, utilizada para acceder a la vista previa de la cámara.
    var lastCreatedView: CameraPreviewView? = null

    // Método que crea una instancia de CameraPreviewView.
    // Este método es llamado por Flutter cuando se necesita una vista de cámara.
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // Crea una nueva instancia de CameraPreviewView y la almacena como la última vista creada.
        // Esta vista se utilizará para mostrar la vista previa de la cámara en la aplicación Flutter.
        val view = CameraPreviewView(context)
        lastCreatedView = view
        return view
    }
}
