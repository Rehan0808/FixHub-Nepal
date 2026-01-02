import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> execute(AuthEntity user) async {
    await repository.signUp(user);
  }
}
