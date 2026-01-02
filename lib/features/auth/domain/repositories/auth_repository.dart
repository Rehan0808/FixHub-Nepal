import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<void> signUp(AuthEntity user);
  Future<AuthEntity?> login(String email, String password);
}
