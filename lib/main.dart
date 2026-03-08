import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/hive_services.dart';
import 'core/api/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_hive_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/presentation/controllers/auth_controller.dart';
import 'theme/theme_provider.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:light_sensor/light_sensor.dart';
import 'dart:async';
import 'features/splash/splash_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'theme/theme_data.dart';
import 'features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'features/admin/presentation/pages/admin_chat_screen.dart';
import 'features/admin/presentation/pages/admin_bookings_screen.dart';
import 'features/notifications/services/notification_service.dart';

import 'package:http/http.dart' as http;
import 'package:shake/shake.dart';
import 'features/support/presentation/widgets/report_problem_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final hiveService = HiveService();
    // Timeout for Hive in case of disk issues on specific phone hardware
    await hiveService.init().timeout(const Duration(seconds: 5));
    await WakelockPlus.enable();
  } catch (e) {
    debugPrint("HIVE_INIT_ERROR: $e");
  }

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();

  try {
    // Initialize auth controller and its dependencies
    final remoteDatasource = AuthRemoteDataSourceImpl(ApiClient(http.Client()));
    final repository = AuthRepositoryImpl(remoteDatasource);
    final loginUseCase = LoginUseCase(repository);
    final signUpUseCase = SignUpUseCase(repository);
    final authController = AuthController(
      loginUseCase: loginUseCase,
      signUpUseCase: signUpUseCase,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          Provider<AuthController>.value(value: authController),
          ChangeNotifierProvider(create: (_) {
            final svc = NotificationService();
            return svc;
          }),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint("APP_STARTUP_ERROR: $e");
  }

  // Initialize Shake Detector for global "Shake to Report"
  ShakeDetector.autoStart(
    onPhoneShake: (event) {
      debugPrint("SHAKE_DETECTED: Opening report dialog...");
      final context = navigatorKey.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => const ReportProblemDialog(),
        );
      }
    },
    shakeThresholdGravity: 2.7,
  );
}

// Global Navigator Key to show dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, // Connect the global key
          debugShowCheckedModeBanner: false,
          title: 'Fixhub Nepal',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashPage(),
          routes: {
            '/admin/dashboard': (context) => const AdminDashboardScreen(),
            '/admin/chat': (context) => const AdminChatScreen(),
            '/admin/bookings': (context) => const AdminBookingsScreen(),
          },
        );
      },
    );
  }
}
