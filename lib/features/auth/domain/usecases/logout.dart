import '../repositories/auth_repository.dart';

/// Use case for user logout.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Execute the logout use case.
  Future<void> call() {
    return _repository.logout();
  }
}
