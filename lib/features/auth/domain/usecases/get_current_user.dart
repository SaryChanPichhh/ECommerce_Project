import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the current authenticated user.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Execute the get current user use case.
  Future<User?> call() {
    return _repository.getCurrentUser();
  }
}
