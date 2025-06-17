// 📁 lib/theme/theme.dart
import 'package:flutter/material.dart';

final ThemeData eirixTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D0D0D), // fondo oscuro limpio
  primaryColor: const Color(0xFF00FFFF), // cian neón
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00FFFF),
    secondary: Color(0xFFFF00FF),
    surface: Color(0xFF1A1A1A),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00FFFF),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: const Color(0xFF00FFFF).withValues(alpha: 102),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D0D0D),
    elevation: 0,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    iconTheme: IconThemeData(color: Color(0xFF00FFFF)),
  ),
);




// ✅ Aplica el estilo automáticamente en todas las pantallas definidas
// Para modificar el fondo o el botón individualmente, siempre usar el Theme:
// Theme.of(context).colorScheme.primary o Theme.of(context).textTheme.headlineLarge
