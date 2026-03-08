// import '../../../core/api/api_client.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_model.dart';


abstract class AuthRemoteDataSource {
  Future<void> signup(AuthModel user);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> sendResetOtp(String email);
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> signup(AuthModel user) async {
    final fullName = '${user.firstName} ${user.lastName}';
    await apiClient.post(ApiEndpoints.signup, {
      "email": user.email,
      "password": user.password,
      "fullName": fullName,
    });
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(ApiEndpoints.login, {
      "email": email,
      "password": password,
    });
    return {'user': response["data"], 'token': response["token"]};
  }

  @override
  Future<void> sendResetOtp(String email) async {
    await apiClient.post(ApiEndpoints.forgotPasswordOtp, {"email": email});
  }

  @override
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    await apiClient.post(ApiEndpoints.resetPasswordOtp, {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    });
  }
}
