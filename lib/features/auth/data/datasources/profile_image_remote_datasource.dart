import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_endpoints.dart';

class ProfileImageRemoteDataSource {
  Future<String> uploadProfileImage(XFile imageFile) async {
    final request =
        http.MultipartRequest('POST', Uri.parse(ApiEndpoints.uploadProfileImage));

    // Read bytes from XFile - works on both web and native
    final bytes = await imageFile.readAsBytes();
    final filename = imageFile.name;
    
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final imageUrl = responseBody.split('"imageUrl":"')[1].split('"')[0];
      return imageUrl;
    } else {
      throw Exception('Image upload failed');
    }
  }
}
