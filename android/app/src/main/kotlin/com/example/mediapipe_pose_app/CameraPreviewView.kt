package com.example.mediapipe_pose_app

import android.content.Context
import android.view.View
import androidx.camera.view.PreviewView
import io.flutter.plugin.platform.PlatformView

class CameraPreviewView(private val context: Context) : PlatformView {

    val previewView: PreviewView = PreviewView(context).apply {
        scaleX = -1f // espejo
    }

    override fun getView(): View = previewView

    override fun dispose() {}
}
