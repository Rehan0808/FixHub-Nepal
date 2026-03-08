import 'package:image_picker/image_picker.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> uploadProfileImage(XFile imagePath, String token);
}
