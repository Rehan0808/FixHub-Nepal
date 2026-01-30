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
  Future<AuthEntity?> login(String email, String password) async {
    final AuthModel userModel =
        await remoteDataSource.login(email, password);

    return AuthEntity(
      id: userModel.id,
      email: userModel.email,
      password: password,
      firstName: userModel.firstName,
      lastName: userModel.lastName,
      phone: userModel.phone,
      address: userModel.address,
    );
  }
}
