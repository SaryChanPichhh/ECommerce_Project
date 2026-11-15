import '../../domain/entities/user.dart';

/// User data model with JSON serialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatar,
    super.role,
    super.createdAt,
  });

  /// Create from JSON map (handles both wrapped `{ "data": { ... } }` and flat maps).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final id = (data['id'] ?? data['user_id'])?.toString() ?? '';
    final email = data['email']?.toString() ?? '';

    // Build full name from name / full_name or first_name + last_name
    String name = (data['name'] ?? data['full_name'])?.toString().trim() ?? '';
    if (name.isEmpty) {
      final firstName = data['first_name']?.toString().trim() ?? '';
      final lastName = data['last_name']?.toString().trim() ?? '';
      name = [
        if (firstName.isNotEmpty) firstName,
        if (lastName.isNotEmpty) lastName,
      ].join(' ');
    }
    if (name.isEmpty && email.isNotEmpty) {
      name = email.split('@').first;
    }

    final phone = (data['phone'] ?? data['phone_number'])?.toString();
    final avatar = (data['avatar'] ?? data['avatar_url'])?.toString();

    String? role = data['role']?.toString();
    if (role == null &&
        data['roles'] is List &&
        (data['roles'] as List).isNotEmpty) {
      role = (data['roles'] as List).first?.toString();
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
      role: role,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create from User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      createdAt: user.createdAt,
    );
  }
}
