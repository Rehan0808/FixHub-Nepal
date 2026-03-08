import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/auth_hive_model.dart';

class HiveService {
 
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<AuthHiveModel>? _userBox;
  Box? _profileBox;

  
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    _userBox = await Hive.openBox<AuthHiveModel>('users');
    _profileBox = await Hive.openBox('profile');
  }

  /// For unit tests only — avoids Flutter platform-channel dependency.
  Future<void> initForTest(String dirPath) async {
    Hive.init(dirPath);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    _userBox = await Hive.openBox<AuthHiveModel>('users');
    _profileBox = await Hive.openBox('profile');
  }

 
  Box<AuthHiveModel> get userBox {
    if (_userBox == null) {
      throw Exception("Hive box is not initialized. Call init() first.");
    }
    return _userBox!;
  }

  Box get profileBox {
    if (_profileBox == null) {
      throw Exception("Hive profile box is not initialized. Call init() first.");
    }
    return _profileBox!;
  }
}
