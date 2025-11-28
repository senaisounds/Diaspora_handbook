import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color purpleBackground = Color(0xFF4E2A5E); // Deep Purple from image
  static const Color goldAccent = Color(0xFFFFD700); // Gold/Yellow from image
  static const Color whiteText = Colors.white;
  static const Color lightText = Colors.white70;
  
  // Chat/Community Colors
  static const Color backgroundColor = Color(0xFF1A1A1A); // Dark background for chat
  static const Color surfaceColor = Color(0xFF2D2D2D); // Surface color for cards/containers
  static const Color primaryColor = goldAccent; // Primary accent color

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: purpleBackground,
    scaffoldBackgroundColor: purpleBackground,
    cardColor: Colors.transparent, // We'll manage card backgrounds manually or use simple dividers
    appBarTheme: AppBarTheme(
      backgroundColor: purpleBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: whiteText,
        letterSpacing: 1.2,
      ),
      iconTheme: const IconThemeData(color: whiteText),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: whiteText
      ),
      // "WEEK 5" big text
      displayMedium: GoogleFonts.montserrat(
        fontSize: 40, 
        fontWeight: FontWeight.bold, 
        color: goldAccent
      ),
      // Event Titles
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: goldAccent,
        letterSpacing: 0.5,
      ),
      // Date/Time/Location
      bodyLarge: GoogleFonts.lato(
        fontSize: 16, 
        color: whiteText,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14, 
        color: lightText
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: goldAccent,
      secondary: goldAccent,
      surface: purpleBackground,
      error: Color(0xFFCF6679),
      onPrimary: purpleBackground,
      onSurface: whiteText,
    ),
    useMaterial3: true,
    dividerColor: goldAccent.withOpacity(0.5),
  );
}
