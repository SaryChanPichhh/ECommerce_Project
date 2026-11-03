import '../entities/user.dart';

/// Auth repository contract — domain layer.
/// No Flutter/GetX/Dio dependencies.
abstract class AuthRepository {
  /// Log in with email and password.
  /// Returns the authenticated [User].
  Future<User> login({required String email, required String password});

  /// Register a new account (Customer or Admin).
  /// Returns the newly created and authenticated [User].
  Future<User> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
  });

  /// Log out the current user.
  Future<void> logout();

  /// Get the currently authenticated user.
  /// Returns null if not authenticated.
  Future<User?> getCurrentUser();

  /// Check if the user is authenticated.
  bool isAuthenticated();

  /// Request a password reset instructions/token to email.
  Future<String> forgotPassword(String email);

  /// Complete password reset using token and new password.
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Refresh JWT access token.
  Future<String> refreshToken();

  /// Update user profile via PATCH /users/me/
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  });
}
