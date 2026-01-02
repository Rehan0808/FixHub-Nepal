class AuthEntity {
  final String id;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;

  AuthEntity({
    required this.id,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
  });
}
