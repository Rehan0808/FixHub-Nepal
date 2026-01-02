import 'package:hive/hive.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  AuthHiveModel({
    required this.id,
    required this.email,
    required this.password,
  });
}
