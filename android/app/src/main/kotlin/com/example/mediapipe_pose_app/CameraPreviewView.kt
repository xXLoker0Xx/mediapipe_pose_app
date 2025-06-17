package com.example.mediapipe_pose_app

import android.content.Context
import android.view.View
import androidx.camera.view.PreviewView
import io.flutter.plugin.platform.PlatformView

// Esta clase representa la vista previa de la cámara en la aplicación Flutter.
class CameraPreviewView(private val context: Context) : PlatformView {

    // Vista previa de la cámara que se mostrará en la aplicación Flutter.
    // Se utiliza PreviewView de CameraX para mostrar el video en tiempo real.
    val previewView: PreviewView = PreviewView(context).apply {
        // Configuración de la vista previa de la cámara.
        // Aquí puedes ajustar la configuración de la vista previa según tus necesidades.

        // Configura la vista previa para que se muestre en modo espejo.
        // Esto es útil si estás utilizando la cámara frontal y deseas que la imagen se vea como en un espejo.
        // scaleX = -1f // espejo

        // Configura el tipo de escala de la vista previa.
        // FILL_CENTER es una opción que ajusta la vista previa para llenar el espacio disponible,
        scaleType = PreviewView.ScaleType.FILL_START

        // Forzar el uso de TextureView en lugar de SurfaceView
        // Esto es necesario para que se integre correctamente dentro de la jerarquía de widgets de Flutter
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    }

    // Método requerido por PlatformView para obtener la vista que se mostrará en Flutter.
    // Este método devuelve la vista previa de la cámara que hemos configurado.
    override fun getView(): View = previewView

    // Método requerido por PlatformView, pero no se utiliza en este caso.
    override fun dispose() {}
}
