import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({
    required String id,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) : super(
          id: id,
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          address: address,
        );

  /// Convert JSON → Model (API response)
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'],
      password: '', // ⚠️ password NEVER comes from API
      firstName: json['firstName'],
      lastName: json['lastName'],
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
