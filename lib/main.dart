import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(EirixApp());
}

class PoseDetectorChannel {
  static const _channel = MethodChannel('pose_detector');

  static Future<String?> startPoseDetection() async {
    return await _channel.invokeMethod<String>('startPoseDetection');
  }
}