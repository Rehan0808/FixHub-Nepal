import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_image_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileImageRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserProfileEntity> uploadProfileImage(XFile imagePath) async {
    final imageUrl = await remoteDataSource.uploadProfileImage(imagePath);
    return UserProfileEntity(imageUrl: imageUrl);
  }
}
