// import '../../../core/api/api_client.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> signup(AuthModel user);
  Future<AuthModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> signup(AuthModel user) async {
    await apiClient.post(
      ApiEndpoints.signup,
      {
        "email": user.email,
        "password": user.password,
        "firstName": user.firstName,
        "lastName": user.lastName,
        "phone": user.phone,
        "address": user.address,
      },
    );
  }

  @override
  Future<AuthModel> login(String email, String password) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      {
        "email": email,
        "password": password,
      },
    );

    return AuthModel.fromJson(response["user"]);
  }
}
