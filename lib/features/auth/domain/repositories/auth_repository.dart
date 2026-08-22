import '../entities/user.dart';

/// Auth repository contract — domain layer.
/// No Flutter/GetX/Dio dependencies.
abstract class AuthRepository {
  /// Log in with email and password.
  /// Returns the authenticated [User].
  Future<User> login({required String email, required String password});

  /// Log out the current user.
  Future<void> logout();

  /// Get the currently authenticated user.
  /// Returns null if not authenticated.
  Future<User?> getCurrentUser();

  /// Check if the user is authenticated.
  bool isAuthenticated();
}
