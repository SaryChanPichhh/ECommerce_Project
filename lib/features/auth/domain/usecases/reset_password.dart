import '../repositories/auth_repository.dart';

/// Use case for resetting user password using token.
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Execute the reset password use case.
  Future<String> call({
    required String resetToken,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
