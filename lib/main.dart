import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add provider

import 'core/services/hive_services.dart';
import 'core/api/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_hive_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/presentation/controllers/auth_controller.dart';

import 'features/splash/splash_page.dart';

import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init(); // Initialize Hive and open boxes

  // Initialize datasources, repository, usecases, controller
  final userBox = hiveService.userBox;
  final localDatasource = AuthHiveDataSource(userBox);
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
        Provider<AuthController>.value(value: authController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // Splash screen first
    );
  }
}
