import 'package:flutter/material.dart';

ThemeData lightMode() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3A86FF), // Bold blue for actions
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Very light grey
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Color(0xFF3A3A3A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    colorScheme: const ColorScheme.light(
      primary:  Color(0xFF3A86FF),
      secondary:  Color(0xFFFF006E), // Hot pink for alerts/emphasis
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
      bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF444444)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3A86FF)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A86FF),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A86FF)),
      ),

      hintStyle: const TextStyle(color: Color(0xFF999999)),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF3A3A3A)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF006E),
      foregroundColor: Colors.white,
    ),

    dividerColor: const Color(0xFFE0E0E0),
  );
}