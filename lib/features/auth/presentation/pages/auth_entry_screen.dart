import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/api/api_client.dart';
import 'forgot_password_otp_screen.dart';
import 'package:http/http.dart' as http;
class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
final authRepository = AuthRepositoryImpl(
  AuthRemoteDataSourceImpl(ApiClient(http.Client())),
);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          child: Text('Forgot Password?'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ForgotPasswordOtpScreen(
                  onSendOtp: authRepository.sendResetOtp,
                  onResetPassword: authRepository.resetPasswordWithOtp,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
