import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/auth_hive_model.dart';

class HiveService {
 
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<AuthHiveModel>? _userBox;

  
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AuthHiveModelAdapter());
    _userBox = await Hive.openBox<AuthHiveModel>('users');
  }

 
  Box<AuthHiveModel> get userBox {
    if (_userBox == null) {
      throw Exception("Hive box is not initialized. Call init() first.");
    }
    return _userBox!;
  }
}
