import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  /// 🔹 SIGN UP USING API
  @override
  Future<void> signUp(AuthEntity user) async {
    final model = AuthModel(
      id: user.id,
      email: user.email,
      password: user.password,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      address: user.address,
    );
    await remoteDataSource.signup(model);
  }

  /// 🔹 LOGIN USING API
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final userJson = response['user'];
    final token = response['token'];
    final userModel = AuthModel.fromJson(userJson);
    return {
      'user': AuthEntity(
        id: userModel.id,
        email: userModel.email,
        password: password,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        phone: userModel.phone,
        address: userModel.address,
      ),
      'token': token,
    };
  }

  /// 🔹 SEND RESET OTP (MOBILE)
  @override
  Future<void> sendResetOtp(String email) async {
    await remoteDataSource.sendResetOtp(email);
  }

  /// 🔹 RESET PASSWORD WITH OTP (MOBILE)
  @override
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    await remoteDataSource.resetPasswordWithOtp(email, otp, newPassword);
  }
}
