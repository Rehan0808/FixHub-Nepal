
import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandRed = Color(0xFFD32F2F);
  static const Color brandRedDark = Color(0xFFB71C1C);

  static ThemeData lightTheme = ThemeData(
    primaryColor: brandRed,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    fontFamily: 'Poppins', // apply globally
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: brandRed,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brandRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
