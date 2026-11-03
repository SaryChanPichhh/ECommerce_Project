import '../repositories/auth_repository.dart';

/// Use case for requesting password reset.
class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Execute the forgot password use case.
  Future<String> call({required String email}) {
    return _repository.forgotPassword(email);
  }
}
