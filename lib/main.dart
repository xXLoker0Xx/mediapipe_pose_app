import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EirixApp());
}

class PoseDetectorChannel {
  static const _channel = MethodChannel('pose_detector');

  static Future<String?> startPoseDetection() async {
    return await _channel.invokeMethod<String>('startPoseDetection');
  }
}