import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:app_settings/app_settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../auth/data/repositories/profile_repository_impl.dart';
import '../../../auth/data/datasources/profile_image_remote_datasource.dart';
import '../../../auth/domain/usecases/upload_profile_image_usecase.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import '../../../../theme/theme_provider.dart';
import '../../../../core/services/hive_services.dart';
import '../../../../theme/theme_data.dart';

import '../../../../core/api/api_endpoints.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  String? _localImagePath;
  bool isUploading = false;
  bool isFingerprintEnabled = false;
  late Box profileBox;
  final LocalAuthentication auth = LocalAuthentication();

  /// Rebuild image URL with current base so it always works on the current device/IP
  String? get _resolvedProfileImageUrl {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) return null;
    final url = profileImageUrl!;
    // If the stored URL contains a host, extract the path portion after the port
    if (url.startsWith('http')) {
      try {
        final uri = Uri.parse(url);
        // path is like /uploads/image.jpg
        final path = uri.path;
        if (path.isNotEmpty) {
          return '${ApiEndpoints.uploadsBaseUrl}$path';
        }
      } catch (_) {}
    }
    // Fallback: rebuild via serviceImageUrl
    return ApiEndpoints.serviceImageUrl(url);
  }

  /// Returns a local FileImage if an offline-saved image exists, otherwise a NetworkImage.
  ImageProvider? get _effectiveProfileImage {
    if (_localImagePath != null && _localImagePath!.isNotEmpty) {
      final file = File(_localImagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    final url = _resolvedProfileImageUrl;
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return null;
  }

  // User data
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    profileBox = HiveService().profileBox;

    setState(() {
      profileImageUrl = profileBox.get('profileImageUrl');
      _localImagePath = profileBox.get('profileImageLocalPath');
      userName = profileBox.get('userName') ?? '';
      userEmail = profileBox.get('userEmail') ?? '';
      userPhone = profileBox.get('userPhone') ?? '';
      userAddress = profileBox.get('userAddress') ?? '';
      isFingerprintEnabled = profileBox.get('isFingerprintEnabled') ?? false;
    });
  }

  Future<void> _saveProfileImage(String imageUrl) async {
    await profileBox.put('profileImageUrl', imageUrl);
    // Clear pending local image now that it's uploaded to server
    await profileBox.delete('profileImageLocalPath');
    await profileBox.delete('profileImagePendingSync');
    setState(() => _localImagePath = null);
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => isUploading = true);

    try {
      final remoteDataSource = ProfileImageRemoteDataSource();
      final repository = ProfileRepositoryImpl(remoteDataSource);
      final useCase = UploadProfileImageUseCase(repository);

      // Get auth token from Hive or your auth provider
      final token = profileBox.get('authToken');
      if (token == null) throw Exception('No authentication token found');

      final result = await useCase.execute(pickedFile, token);
      final imageUrl = result.imageUrl;

      setState(() {
        profileImageUrl = imageUrl;
        isUploading = false;
      });

      await _saveProfileImage(imageUrl);
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('No authentication token found')) {
        setState(() => isUploading = false);
        debugPrint('Profile image upload failed (no token): $e');
      } else {
        // Network/upload failure — save image locally
        final localPath = pickedFile.path;
        await profileBox.put('profileImageLocalPath', localPath);
        await profileBox.put('profileImagePendingSync', true);
        setState(() {
          _localImagePath = localPath;
          isUploading = false;
        });
        debugPrint('Profile image upload failed (saved locally): $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo saved locally ✓ — will upload when back online'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFingerprint(bool enabled) async {
    if (enabled) {
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (!canAuthenticate) {
          _showAuthError('Biometric Not Supported',
              'Your device does not support fingerprint authentication.');
          return;
        }

        final List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();

        if (availableBiometrics.isEmpty) {
          _showSetupFingerprintDialog();
          return;
        }

        final bool authenticated = await auth.authenticate(
          localizedReason: 'Please scan your fingerprint to enable payment security',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          await profileBox.put('isFingerprintEnabled', true);
          setState(() => isFingerprintEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint security enabled for payments! 🛡️')),
          );
        }
      } catch (e) {
        debugPrint("AUTH_ERROR: $e");
      }
    } else {
      await profileBox.put('isFingerprintEnabled', false);
      setState(() => isFingerprintEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint security disabled.')),
      );
    }
  }

  void _showAuthError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSetupFingerprintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Fingerprint'),
        content: const Text(
            'You need to set up a fingerprint on your device to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.security);
            },
            child: const Text('Set Fingerprint'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Image (sized + clipped to avoid overflow from border + camera icon)
                      GestureDetector(
                        onTap: isUploading ? null : pickAndUploadImage,
                        child: SizedBox(
                          width: 116,
                          height: 116,
                          child: ClipRect(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: (Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.1),
                                    backgroundImage: _effectiveProfileImage,
                                    onBackgroundImageError: _effectiveProfileImage != null
                                        ? (e, s) {
                                            debugPrint('Profile image load error: $e');
                                          }
                                        : null,
                                    child: _effectiveProfileImage == null
                                        ? Icon(
                                            Icons.person,
                                            size: 48,
                                            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
                                          )
                                        : null,
                                  ),
                                ),
                                if (isUploading)
                                  CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                if (!isUploading)
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName.isEmpty ? 'User Name' : userName,
                        style: TextStyle(
                          color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail.isEmpty ? 'user@email.com' : userEmail,
                        style: TextStyle(
                          color: (Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileInfoCard(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: userName,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: userEmail,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: userPhone,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: userAddress,
                  ),

                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    icon: Icons.brightness_6_outlined,
                    title: 'App Theme',
                    trailing: Consumer<ThemeProvider>(
                      builder: (context, provider, child) {
                        return DropdownButton<AppThemeMode>(
                          value: provider.selection,
                          underline: const SizedBox(),
                          onChanged: (mode) {
                            if (mode != null) provider.setThemeMode(mode);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: AppThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: AppThemeMode.dark,
                              child: Text('Dark'),
                            ),
                            DropdownMenuItem(
                              value: AppThemeMode.auto,
                              child: Text('Auto'),
                            ),
                            DropdownMenuItem(
                              value: AppThemeMode.proximity,
                              child: Text('Proximity'),
                            ),
                          ],
                        );
                      },
                    ),
                    onTap: () {}, // Handled by dropdown interaction
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          _loadProfileData();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.fingerprint,
                    title: 'Fingerprint for Payments',
                    trailing: Switch(
                      value: isFingerprintEnabled,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => _toggleFingerprint(val),
                    ),
                    onTap: () => _toggleFingerprint(!isFingerprintEnabled),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications settings coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & support coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy policy coming soon')),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle logout
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: AppTheme.primary),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
