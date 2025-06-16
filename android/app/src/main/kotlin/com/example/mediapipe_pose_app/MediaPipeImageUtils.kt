import android.graphics.ImageFormat
import android.graphics.YuvImage
import android.media.Image
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.nio.ByteBuffer

//                     channel.invokeMethod("onPoseDetected", landmarkData)
//                 .build()

object MediaPipeImageUtils {
    // Convierte una imagen de tipo Image a MPImage, aplicando una rotación si es necesario.
    fun imageToMPImage(image: Image, rotation: Int): MPImage {
        // Verifica que la imagen no sea nula
        val nv21 = yuv420ToNv21(image)
        // Convierte la imagen YUV420 a NV21, que es un formato compatible con YuvImage
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, image.width, image.height, null)
        // Comprime la imagen YUV a JPEG para convertirla a un Bitmap
        // Usamos ByteArrayOutputStream para almacenar la imagen comprimida
        val out = ByteArrayOutputStream()
        // Comprime la imagen YUV a JPEG con calidad máxima (100)
        // Esto convierte la imagen YUV a un formato que puede ser manipulado como Bitmap
        yuvImage.compressToJpeg(android.graphics.Rect(0, 0, image.width, image.height), 100, out)
        // Decodifica el byte array JPEG a un Bitmap
        // Esto crea un Bitmap a partir de los datos JPEG comprimidos
        val jpegData = out.toByteArray()
        // Decodifica el byte array JPEG a un Bitmap
        // BitmapFactory.decodeByteArray convierte el byte array JPEG a un Bitmap
        val bitmap = BitmapFactory.decodeByteArray(jpegData, 0, jpegData.size)

        // Rota el Bitmap si es necesario
        // Si la imagen necesita ser rotada (por ejemplo, si se usa la cámara frontal), rota el Bitmap
        val rotatedBitmap = rotateBitmap(bitmap, rotation)
        // Crea un BitmapImageBuilder a partir del Bitmap rotado
        // BitmapImageBuilder es una clase de MediaPipe que permite crear un MPImage a partir de un Bitmap
        return BitmapImageBuilder(rotatedBitmap).build()
    }

    private fun yuv420ToNv21(image: Image): ByteArray {
        // Convierte una imagen YUV420 a NV21, que es un formato compatible con YuvImage
        val yBuffer = image.planes[0].buffer
        val uBuffer = image.planes[1].buffer
        val vBuffer = image.planes[2].buffer

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + uSize + vSize)

        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)

        return nv21
    }

    // Rota un Bitmap según el número de grados especificado
    // Esta función utiliza una matriz de transformación para rotar el Bitmap
    private fun rotateBitmap(source: Bitmap, degrees: Int): Bitmap {
        // Si los grados son 0, no es necesario rotar la imagen
        // Si los grados son 0, simplemente devuelve el Bitmap original
        if (degrees == 0) return source
        //  Crea una matriz de transformación para rotar el Bitmap
        // Utiliza android.graphics.Matrix para crear una matriz de transformación
        val matrix = android.graphics.Matrix().apply { postRotate(degrees.toFloat()) }
        // Crea un nuevo Bitmap rotado a partir del Bitmap original y la matriz de transformación
        // Utiliza Bitmap.createBitmap para crear un nuevo Bitmap rotado
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    }
}