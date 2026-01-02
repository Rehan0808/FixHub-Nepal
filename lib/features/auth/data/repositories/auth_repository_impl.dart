import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_hive_datasource.dart';
import '../models/auth_hive_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthHiveDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<void> signUp(AuthEntity user) async {
    final model = AuthHiveModel(
      id: user.id,
      email: user.email,
      password: user.password,
    );
    await dataSource.addUser(model);
  }

  @override
  Future<AuthEntity?> login(String email, String password) async {
    final user = dataSource.getUser(email);
    if (user != null && user.password == password) {
      return AuthEntity(id: user.id, email: user.email, password: user.password);
    }
    return null;
  }
}
