/// Model for registration request payload.
class RegisterRequestModel {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? role;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.role,
  });

  /// Convert to JSON map for API request.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (firstName != null && firstName!.trim().isNotEmpty) {
      map['first_name'] = firstName!.trim();
    }
    if (lastName != null && lastName!.trim().isNotEmpty) {
      map['last_name'] = lastName!.trim();
    }
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      map['phone_number'] = phoneNumber!.trim();
    }
    if (role != null && role!.trim().isNotEmpty) {
      map['role'] = role!.trim();
    }
    return map;
  }
}
