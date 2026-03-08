import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Matching Web Frontend
  static const Color primary = Color(0xFFEF4444); // #ef4444
  static const Color primaryDark = Color(0xFFDC2626); // #dc2626
  static const Color primaryLight = Color(0xFFF87171); // #f87171
  static const Color accent = Color(0xFFF59E0B); // #f59e0b (amber/orange)
  static const Color dark = Color(0xFF111827); // #111827
  static const Color darkLight = Color(0xFF1F2937); // #1f2937
  static const Color success = Color(0xFF10B981); // #10b981
  static const Color danger = Color(0xFFEF4444); // #ef4444
  static const Color grayBorder = Color(0xFFE5E7EB); // #e5e7eb
  static const Color backgroundLight = Color(0xFFF9FAFB); // Light gray background
  static const Color white = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  // Background Gradient Colors (for auth screens)
  static const Color bgDark = Color(0xFF0F172A); // slate-950

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: white,
    fontFamily: 'Poppins',
    
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: white,
      error: danger,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: grayBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: grayBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger),
      ),
      labelStyle: const TextStyle(
        color: textGray,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: textLight,
      ),
    ),
    
    cardTheme: const CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: grayBorder, width: 1),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      backgroundColor: white,
      elevation: 8,
    ),
    
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(color: white),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: dark,
    fontFamily: 'Poppins',
    
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: darkLight,
      error: danger,
      onSurface: white,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: dark,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger),
      ),
      labelStyle: const TextStyle(
        color: textLight,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: textGray,
      ),
    ),
    
    cardTheme: const CardThemeData(
      color: darkLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: darkLight, width: 1),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      backgroundColor: dark,
      elevation: 8,
    ),
    
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(color: white),
    ),
  );
}
