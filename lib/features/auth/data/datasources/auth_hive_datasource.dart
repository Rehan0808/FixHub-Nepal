import 'package:hive/hive.dart';
import '../models/auth_hive_model.dart';

class AuthHiveDataSource {
  final Box<AuthHiveModel> userBox;

  AuthHiveDataSource(this.userBox);

  Future<void> addUser(AuthHiveModel user) async {
    await userBox.put(user.email, user);
  }

  AuthHiveModel? getUser(String email) {
    return userBox.get(email);
  }
}
