import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating the authenticated user's profile.
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<User> call({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      preferredLanguage: preferredLanguage,
      marketingOptIn: marketingOptIn,
    );
  }
}
