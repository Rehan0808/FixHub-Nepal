// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/theme_data.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const FixHubApp());
}

class FixHubApp extends StatelessWidget {
  const FixHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
