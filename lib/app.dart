import 'package:flutter/material.dart';
import 'package:mediapipe_pose_app/screens/camera/camera_screen.dart';
import 'package:mediapipe_pose_app/screens/paciente/home_paciente.dart';
import 'package:mediapipe_pose_app/screens/profesional/home_prof.dart';
import 'package:mediapipe_pose_app/screens/shared/login.dart';
import 'package:mediapipe_pose_app/screens/shared/profile.dart';
import 'package:mediapipe_pose_app/screens/shared/signup.dart';
import '../../screens/shared/welcome.dart';
import '../../theme/theme.dart';

class EirixApp extends StatelessWidget {
  const EirixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eirix',
      theme: eirixTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/homepatient': (context) => const HomePacienteScreen(),
        '/homeprofessional': (context) => const HomeProfessionalScreen(),
        '/camera': (context) => const CameraScreen(),
        '/perfil': (context) => const ProfileScreen(),

        // Rutas aún no implementadas pero necesarias:
        // '/historial': (context) => const PlaceholderScreen(title: 'Historial'),
        // '/rutinas': (context) => const PlaceholderScreen(title: 'Rutinas'),
        // '/register': (context) => const PlaceholderScreen(title: 'Registro'),
      },
    );
  }
} 