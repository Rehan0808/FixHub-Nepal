import 'package:flutter/material.dart';
import 'core/services/hive_services.dart';
import 'features/splash/splash_page.dart'; // <-- splash page import


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init(); // Initialize Hive and open boxes

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // <-- show splash first
    );
  }
}

