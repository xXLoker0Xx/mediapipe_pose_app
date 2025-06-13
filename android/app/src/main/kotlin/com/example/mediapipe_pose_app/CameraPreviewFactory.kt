package com.example.mediapipe_pose_app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.StandardMessageCodec

class CameraPreviewFactory(
    private val messenger: BinaryMessenger,
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var lastCreatedView: CameraPreviewView? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val view = CameraPreviewView(context)
        lastCreatedView = view
        return view
    }
}
