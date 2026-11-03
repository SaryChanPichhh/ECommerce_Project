import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new customer or admin.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Execute the register use case.
  Future<User> call({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
  }) {
    return _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
    );
  }
}
