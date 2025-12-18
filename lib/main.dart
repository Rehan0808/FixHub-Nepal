import 'package:flutter/material.dart';
import 'package:fixhub_nepal/splash/splash_page.dart';
import 'package:fixhub_nepal/onboarding/on_boarding1.dart';
import 'package:fixhub_nepal/auth/login_page.dart';
import 'package:fixhub_nepal/screens/bottom_screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixHub Nepal',
      theme: ThemeData(
        fontFamily: 'Poppins', // ✅ GLOBAL FONT
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/onboarding': (context) => const Onboarding1(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
