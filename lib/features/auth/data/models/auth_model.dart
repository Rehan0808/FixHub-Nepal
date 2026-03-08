import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({
    required super.id,
    required super.email,
    required super.password,
    super.firstName,
    super.lastName,
    super.phone,
    super.address,
  });

  /// Convert JSON → Model (API response)
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Backend returns "fullName", split it into firstName and lastName
    String? fullName = json['fullName'];
    String? firstName;
    String? lastName;
    
    if (fullName != null && fullName.isNotEmpty) {
      final nameParts = fullName.split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }
    
    return AuthModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      password: '', // ⚠️ password NEVER comes from API
      firstName: firstName ?? json['firstName'],
      lastName: lastName ?? json['lastName'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  /// Convert Model → JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "address": address,
    };
  }
}
