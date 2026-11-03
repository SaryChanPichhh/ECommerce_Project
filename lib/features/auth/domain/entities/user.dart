/// User entity — pure Dart, no framework dependencies.
class User {
  final String id;
  final String name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? role;
  final String? status;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime? createdAt;
  final String? dateOfBirth;
  final String? gender;
  final String? preferredLanguage;
  final bool? marketingOptIn;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.role,
    this.status,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.createdAt,
    this.dateOfBirth,
    this.gender,
    this.preferredLanguage,
    this.marketingOptIn,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    String? role,
    String? status,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    DateTime? createdAt,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          phone == other.phone &&
          avatar == other.avatar &&
          role == other.role &&
          status == other.status &&
          dateOfBirth == other.dateOfBirth &&
          gender == other.gender &&
          preferredLanguage == other.preferredLanguage &&
          marketingOptIn == other.marketingOptIn;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        firstName,
        lastName,
        phone,
        avatar,
        role,
        status,
        dateOfBirth,
        gender,
        preferredLanguage,
        marketingOptIn,
      );

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
