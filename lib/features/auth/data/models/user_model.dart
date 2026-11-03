import '../../domain/entities/user.dart';

/// User data model with JSON serialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.avatar,
    super.role,
    super.status,
    super.emailVerifiedAt,
    super.phoneVerifiedAt,
    super.createdAt,
    super.dateOfBirth,
    super.gender,
    super.preferredLanguage,
    super.marketingOptIn,
  });

  /// Create from JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['user_id']?.toString() ?? '';
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final email = json['email'] as String? ?? '';

    // Extract name
    String name = (json['name'] as String? ?? '').trim();
    if (name.isEmpty) {
      final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      name = combined.isNotEmpty
          ? combined
          : (email.isNotEmpty ? email.split('@').first : 'User');
    }

    // Extract phone
    final phone = (json['phone_number'] ?? json['phone']) as String?;

    // Extract avatar
    final avatar = (json['avatar_url'] ?? json['avatar']) as String?;

    // Extract role
    String? role = json['role'] as String?;
    if (role == null &&
        json['roles'] is List &&
        (json['roles'] as List).isNotEmpty) {
      role = (json['roles'] as List).first.toString();
    }
    if ((role == null || role.isEmpty) && email.toLowerCase().contains('admin')) {
      role = 'admin';
    }

    // Extract profile sub-object if present
    String? dateOfBirth = json['date_of_birth'] as String?;
    String? gender = json['gender'] as String?;
    String? preferredLanguage = json['preferred_language'] as String?;
    bool? marketingOptIn = json['marketing_opt_in'] as bool?;

    if (json['profile'] is Map<String, dynamic>) {
      final profile = json['profile'] as Map<String, dynamic>;
      dateOfBirth ??= profile['date_of_birth']?.toString();
      gender ??= profile['gender']?.toString();
      preferredLanguage ??= profile['preferred_language']?.toString();
      marketingOptIn ??= profile['marketing_opt_in'] as bool?;
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatar: avatar,
      role: role ?? 'customer',
      status: json['status'] as String? ?? 'active',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
      phoneVerifiedAt: json['phone_verified_at'] != null
          ? DateTime.tryParse(json['phone_verified_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      dateOfBirth: dateOfBirth,
      gender: gender,
      preferredLanguage: preferredLanguage,
      marketingOptIn: marketingOptIn,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phone,
      'phone': phone,
      'avatar_url': avatar,
      'avatar': avatar,
      'role': role,
      'status': status,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'preferred_language': preferredLanguage,
      'marketing_opt_in': marketingOptIn,
      'profile': {
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'preferred_language': preferredLanguage,
        'marketing_opt_in': marketingOptIn,
      },
    };
  }

  /// Create from User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      status: user.status,
      emailVerifiedAt: user.emailVerifiedAt,
      phoneVerifiedAt: user.phoneVerifiedAt,
      createdAt: user.createdAt,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      preferredLanguage: user.preferredLanguage,
      marketingOptIn: user.marketingOptIn,
    );
  }
}
