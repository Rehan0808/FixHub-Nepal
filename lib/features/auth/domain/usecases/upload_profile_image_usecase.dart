import 'package:image_picker/image_picker.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<UserProfileEntity> execute(XFile imagePath, String token) {
    return repository.uploadProfileImage(imagePath, token);
  }
}
