import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<void> signUp(AuthEntity user);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> sendResetOtp(String email);
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword);
}
