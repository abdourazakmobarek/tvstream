import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Mauritanian Palette
  static const Color primaryGreen = Color(0xFF00A95C); // Vivid Green
  static const Color deepGreen = Color(0xFF004D2C);    // Darker Green for gradient
  static const Color accentGold = Color(0xFFFFD700);   // Bright Gold
  static const Color midnightBlue = Color(0xFF0F172A); // Rich Blue/Black for contrast
  
  static const Color glassSurface = Color(0x25FFFFFF); // Increased opacity for glass

  // Gradient Background
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepGreen,
      midnightBlue,
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      canvasColor: Colors.transparent, // Important for glass effects
      scaffoldBackgroundColor: midnightBlue, // Fallback
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        secondary: accentGold,
        onSurface: Colors.white,
        brightness: Brightness.dark,
        surfaceContainerHighest: Colors.white.withValues(alpha: 0.1),
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: accentGold, // Gold title
          fontWeight: FontWeight.bold, 
          fontSize: 24, // Larger title
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme; // Enforce this new premium look for now

  // Enhanced Glass Decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: glassSurface,
    borderRadius: BorderRadius.circular(20), // More rounded
    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 15,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      )
    ],
  );
}
