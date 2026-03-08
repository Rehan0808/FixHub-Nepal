import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_endpoints.dart';

class ProfileImageRemoteDataSource {
  /// Uploads profile picture via POST (reliable on mobile; backend also supports PUT for web).
  Future<String> uploadProfileImage(XFile imageFile, String token) async {
    final url = ApiEndpoints.userProfilePictureUpload;
    final request = http.MultipartRequest('POST', Uri.parse(url));

    final bytes = await imageFile.readAsBytes();
    String filename = imageFile.name;
    if (filename.isEmpty || !filename.contains('.')) {
      filename = 'profilePicture.jpg';
    }
    // Use image/jpeg so backend accepts the file (Flutter web often sends octet-stream otherwise)
    final contentType = _imageMediaType(filename);

    request.files.add(
      http.MultipartFile.fromBytes(
        'profilePicture',
        bytes,
        filename: filename,
        contentType: contentType,
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      String msg = 'Image upload failed: ${response.statusCode}';
      try {
        final err = jsonDecode(responseBody) as Map<String, dynamic>?;
        if (err != null && err['message'] != null) msg = err['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>?;
    final relativePath = data?['profilePicture'] as String?;
    if (relativePath == null || relativePath.isEmpty) {
      throw Exception('No profile picture in response');
    }
    // Backend returns path like "uploads/xxx.jpg"; build full URL for display
    return ApiEndpoints.serviceImageUrl(relativePath);
  }

  static MediaType _imageMediaType(String filename) {
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
