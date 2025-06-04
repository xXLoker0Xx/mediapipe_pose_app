// MainActivity.kt

package com.example.mediapipe_pose_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "pose_detector"
    private lateinit var poseAnalyzer: PoseAnalyzer

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val channel = MethodChannel(messenger, CHANNEL)

        poseAnalyzer = PoseAnalyzer(this, channel)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "startPoseDetection") {
                poseAnalyzer.setup()
                result.success("Pose detection started")
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        poseAnalyzer.close()
    }
}
