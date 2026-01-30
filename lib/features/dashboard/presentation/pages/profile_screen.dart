import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import '../../auth/data/datasources/profile_image_remote_datasource.dart';
// import '../../auth/data/repositories/profile_repository_impl.dart';
// import '../../auth/domain/usecases/upload_profile_image_usecase.dart';
import '../../../auth/data/repositories/profile_repository_impl.dart';
import '../../../auth/data/datasources/profile_image_remote_datasource.dart';
import '../../../auth/domain/usecases/upload_profile_image_usecase.dart';
// import '../../../core/services/hive_services.dart';
import '../../../../core/services/hive_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  bool isUploading = false;
  late Box profileBox;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    profileBox = HiveService().profileBox;
    final savedImageUrl = profileBox.get('profileImageUrl');
    if (savedImageUrl != null) {
      setState(() {
        profileImageUrl = savedImageUrl;
      });
    }
  }

  Future<void> _saveProfileImage(String imageUrl) async {
    await profileBox.put('profileImageUrl', imageUrl);
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => isUploading = true);

    final remoteDataSource = ProfileImageRemoteDataSource();
    final repository = ProfileRepositoryImpl(remoteDataSource);
    final useCase = UploadProfileImageUseCase(repository);

    final result = await useCase.execute(picked);

    setState(() {
      // Convert LAN IP to localhost for web platform
      String imageUrl = result.imageUrl;
      imageUrl = imageUrl.replaceFirst(
        '192.168.1.97:5000',
        'localhost:5000',
      );
      profileImageUrl = imageUrl;
      isUploading = false;
    });

    // Save to local storage
    await _saveProfileImage(profileImageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isUploading ? null : pickAndUploadImage,
            child: Text(isUploading ? 'Uploading...' : 'Upload Profile Image'),
          ),
        ],
      ),
    );
  }
}
