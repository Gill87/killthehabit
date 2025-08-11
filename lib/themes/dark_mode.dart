import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

  ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3A86FF), // Same bold blue for actions
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
    
    fontFamily: GoogleFonts.ubuntu().fontFamily,
    
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F1F1F), // Darker app bar background
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
      titleTextStyle: GoogleFonts.ubuntu(
        color: const Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3A86FF),
      secondary: Color(0xFFFF006E), // Hot pink emphasis
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
    ),
    
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.ubuntu(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: Colors.white70,
      ),
      titleMedium: GoogleFonts.ubuntu(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.ubuntu(
        fontSize: 16, 
        color: Colors.white60,
      ),
      labelLarge: GoogleFonts.ubuntu(
        fontSize: 14, 
        fontWeight: FontWeight.bold, 
        color: Color(0xFF3A86FF),
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
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A86FF)),
      ),
      hintStyle: GoogleFonts.ubuntu(color: const Color(0xFFAAAAAA)),
    ),
    
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    
    iconTheme: const IconThemeData(color: Colors.white70),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF006E),
      foregroundColor: Colors.white,
    ),

    
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1F1F1F),
      selectedItemColor: const Color(0xFF3A86FF),
      unselectedItemColor: const Color(0xFF777777),
      selectedLabelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.ubuntu(color: const Color(0xFF777777)),
    ),
    
    dividerColor: const Color(0xFF444444),
  );
