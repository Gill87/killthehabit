import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

  ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3A86FF), // Bold blue for actions
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Very light grey
    
    // Apply Ubuntu font to all text in the app
    fontFamily: GoogleFonts.ubuntu().fontFamily,
    
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 220, 217, 217), // Soft amber for app bar
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xFF3A3A3A)),
      titleTextStyle: GoogleFonts.ubuntu(
        color: const Color(0xFF1E1E1E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
          
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3A86FF),
      secondary: Color(0xFFFF006E), // Hot pink for alerts/emphasis
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
    
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.ubuntu(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: const Color(0xFF1E1E1E)
      ),
      titleMedium: GoogleFonts.ubuntu(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: const Color(0xFF333333)
      ),
      bodyMedium: GoogleFonts.ubuntu(
        fontSize: 16, 
        color: const Color(0xFF444444)
      ),
      labelLarge: GoogleFonts.ubuntu(
        fontSize: 14, 
        fontWeight: FontWeight.bold, 
        color: const Color(0xFF3A86FF)
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A86FF),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
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
      hintStyle: GoogleFonts.ubuntu(color: const Color(0xFF999999)),
    ),
    
    cardTheme: CardThemeData(
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
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white70,
      selectedItemColor: const Color(0xFF3A86FF),
      unselectedItemColor: const Color(0xFF999999),
      selectedLabelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.ubuntu(color: const Color(0xFF999999)),
    ),
    
    dividerColor: const Color(0xFFE0E0E0),
  );