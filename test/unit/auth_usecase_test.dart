// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:fixhub_nepal/features/auth/data/models/auth_model.dart';
import 'package:fixhub_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:fixhub_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:fixhub_nepal/features/auth/domain/usecases/login_usecase.dart';
import 'package:fixhub_nepal/features/auth/domain/usecases/signup_usecase.dart';

// ---------- Manual mock (no code-gen needed) ----------
class _MockAuthRepository implements AuthRepository {
  String? capturedEmail;
  String? capturedPassword;
  AuthEntity? capturedSignUpUser;
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    capturedEmail = email;
    capturedPassword = password;
    if (shouldThrow) throw Exception('Login failed');
    return {'user': {'_id': 'u1', 'email': email}, 'token': 'test_token'};
  }

  @override
  Future<void> signUp(AuthEntity user) async {
    capturedSignUpUser = user;
    if (shouldThrow) throw Exception('SignUp failed');
  }

  @override
  Future<void> sendResetOtp(String email) async {}

  @override
  Future<void> resetPasswordWithOtp(
      String email, String otp, String newPassword) async {}
}

// ======================================================
void main() {
  // ── 1-2: AuthEntity ───────────────────────────────
  group('AuthEntity', () {
    test('1. stores all required and optional fields correctly', () {
      final entity = AuthEntity(
        id: 'test-id',
        email: 'ram@example.com',
        password: 'secret123',
        firstName: 'Ram',
        lastName: 'Shrestha',
        phone: '9800011111',
        address: 'Pokhara',
      );
      expect(entity.id, 'test-id');
      expect(entity.email, 'ram@example.com');
      expect(entity.password, 'secret123');
      expect(entity.firstName, 'Ram');
      expect(entity.lastName, 'Shrestha');
      expect(entity.phone, '9800011111');
      expect(entity.address, 'Pokhara');
    });

    test('2. optional fields default to null when not provided', () {
      final entity = AuthEntity(
        id: 'min-id',
        email: 'min@test.com',
        password: 'pass',
      );
      expect(entity.phone, isNull);
      expect(entity.address, isNull);
      expect(entity.firstName, isNull);
      expect(entity.lastName, isNull);
    });
  });

  // ── 3-8: AuthModel ────────────────────────────────
  group('AuthModel', () {
    test('3. fromJson() parses standard fields including MongoDB _id', () {
      final json = {
        '_id': 'mongo-abc',
        'email': 'sita@test.com',
        'firstName': 'Sita',
        'lastName': 'Rai',
        'phone': '9811234567',
        'address': 'Bhaktapur',
      };
      final model = AuthModel.fromJson(json);
      expect(model.id, 'mongo-abc');
      expect(model.email, 'sita@test.com');
      expect(model.phone, '9811234567');
      expect(model.address, 'Bhaktapur');
    });

    test('4. fromJson() splits fullName into firstName and lastName', () {
      final json = {
        'id': 'u5',
        'email': 'rb@test.com',
        'fullName': 'Ram Bahadur Thapa',
      };
      final model = AuthModel.fromJson(json);
      expect(model.firstName, 'Ram');
      expect(model.lastName, 'Bahadur Thapa');
    });

    test('5. fromJson() handles empty JSON with empty-string defaults', () {
      final model = AuthModel.fromJson({});
      expect(model.id, '');
      expect(model.email, '');
      expect(model.password, '');
    });

    test('6. toJson() contains email key with correct value', () {
      final model = AuthModel(
        id: 'x1',
        email: 'foo@bar.com',
        password: 'hunter2',
      );
      final json = model.toJson();
      expect(json.containsKey('email'), isTrue);
      expect(json['email'], 'foo@bar.com');
    });

    test('7. toJson() includes all profile fields', () {
      final model = AuthModel(
        id: 'y1',
        email: 'a@b.com',
        password: 'p',
        firstName: 'John',
        lastName: 'Doe',
        phone: '9811111111',
        address: 'Lalitpur',
      );
      final json = model.toJson();
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['phone'], '9811111111');
      expect(json['address'], 'Lalitpur');
    });

    test('8. AuthModel is a subtype of AuthEntity', () {
      final model = AuthModel(id: 'z', email: 'z@z.com', password: 'zz');
      expect(model, isA<AuthEntity>());
    });
  });

  // ── 9: LoginUseCase ───────────────────────────────
  group('LoginUseCase', () {
    late _MockAuthRepository repo;
    late LoginUseCase useCase;

    setUp(() {
      repo = _MockAuthRepository();
      useCase = LoginUseCase(repo);
    });

    test('9. execute() forwards credentials to repository.login', () async {
      await useCase.execute('user@test.com', 'pass1234');
      expect(repo.capturedEmail, 'user@test.com');
      expect(repo.capturedPassword, 'pass1234');
    });
  });

  // ── 10: SignUpUseCase ─────────────────────────────
  group('SignUpUseCase', () {
    late _MockAuthRepository repo;
    late SignUpUseCase useCase;

    setUp(() {
      repo = _MockAuthRepository();
      useCase = SignUpUseCase(repo);
    });

    test('10. execute() forwards AuthEntity to repository.signUp', () async {
      final entity = AuthEntity(
        id: 'new-1',
        email: 'new@test.com',
        password: 'newpass',
        firstName: 'Maya',
      );
      await useCase.execute(entity);
      expect(repo.capturedSignUpUser, isNotNull);
      expect(repo.capturedSignUpUser!.email, 'new@test.com');
      expect(repo.capturedSignUpUser!.firstName, 'Maya');
    });
  });
}
