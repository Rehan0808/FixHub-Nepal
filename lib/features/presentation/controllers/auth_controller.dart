import 'package:flutter/material.dart';

// import '../../domain/entities/auth_entity.dart';
// import '../../domain/usecases/login_usecase.dart';
// import '../../domain/usecases/signup_usecase.dart';
// import '../../../dashboard/presentation/pages/main_screen.dart';
// import '../../../auth/presentation/pages/login_page.dart';

import '../../../features/auth/domain/entities/auth_entity.dart';
import '../../../features/auth/domain/usecases/login_usecase.dart';
import '../../../features/auth/domain/usecases/signup_usecase.dart';
import '../../../features/presentation/pages/login_page.dart';
import '../../../features/dashboard/presentation/pages/main_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// import 'login_page.dart';
// import '../../domain/entities/auth_entity.dart';
// import '../controllers/auth_controller.dart';


class AuthController {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;

  AuthController({
    required this.loginUseCase,
    required this.signUpUseCase,
  });

  /// 🔹 LOGIN
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final user = await loginUseCase.execute(email, password);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 🔹 SIGN UP
  Future<void> signUp({
    required BuildContext context,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    try {
      final user = AuthEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
      );

      await signUpUseCase.execute(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup successful"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
