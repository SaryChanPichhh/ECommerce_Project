import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/user_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository].
/// Converts exceptions from data sources into domain-level failures and synchronizes
/// tokens and user identity with the in-memory [UserSession] singleton.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      final Map<String, dynamic> dataMap =
          (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;

      final token = dataMap['access_token'] as String? ??
          dataMap['token'] as String? ??
          response['access_token'] as String? ??
          '';

      final refreshToken = dataMap['refresh_token'] as String? ??
          response['refresh_token'] as String?;

      if (token.isEmpty) {
        throw const ServerException(message: 'Authentication token not found');
      }

      // 1. Save tokens to persistent storage
      await _localDataSource.saveAccessToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _localDataSource.saveRefreshToken(refreshToken);
      }

      // 2. Assign access token to UserSession singleton so HTTP interceptors attach it
      UserSession.instance.setToken(token);

      // 3. Fetch user profile from backend with active Bearer token
      UserModel user;
      try {
        user = await _remoteDataSource.getCurrentUser();
      } catch (_) {
        // Fallback user from login response payload
        user = UserModel(
          id: dataMap['user_id']?.toString() ?? dataMap['id']?.toString() ?? '',
          name: email.split('@').first,
          email: email,
          role: dataMap['role'] as String? ?? 'customer',
        );
      }

      // 4. Save user data to persistent storage and singleton instance
      await _localDataSource.saveUserData(user);
      UserSession.instance.setUser(user);

      return user;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(message: e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
  }) async {
    try {
      final effectiveRole = role ??
          (email.toLowerCase().contains('admin') ? 'admin' : 'customer');

      final response = await _remoteDataSource.register(
        RegisterRequestModel(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          role: effectiveRole,
        ),
      );

      final Map<String, dynamic> dataMap =
          (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;

      final token = dataMap['access_token'] as String? ??
          dataMap['token'] as String? ??
          response['access_token'] as String? ??
          '';

      if (token.isNotEmpty) {
        await _localDataSource.saveAccessToken(token);
        UserSession.instance.setToken(token);
      }

      // Fetch user profile from backend with active Bearer token
      UserModel user;
      try {
        final remoteUser = await _remoteDataSource.getCurrentUser();
        final finalRole = effectiveRole == 'admin'
            ? 'admin'
            : (remoteUser.role ?? 'customer');
        user = UserModel(
          id: remoteUser.id,
          name: remoteUser.name,
          email: remoteUser.email,
          firstName: remoteUser.firstName,
          lastName: remoteUser.lastName,
          phone: remoteUser.phone,
          avatar: remoteUser.avatar,
          role: finalRole,
          status: remoteUser.status,
          dateOfBirth: remoteUser.dateOfBirth,
          gender: remoteUser.gender,
          preferredLanguage: remoteUser.preferredLanguage,
          marketingOptIn: remoteUser.marketingOptIn,
        );
      } catch (_) {
        final combinedName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        user = UserModel(
          id: dataMap['user_id']?.toString() ?? dataMap['id']?.toString() ?? '',
          name: combinedName.isNotEmpty ? combinedName : email.split('@').first,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phoneNumber,
          role: effectiveRole,
        );
      }

      await _localDataSource.saveUserData(user);
      UserSession.instance.setUser(user);

      return user;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(message: e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Even if remote call fails, clear local data
    } finally {
      UserSession.instance.clear();
      await _localDataSource.clearAuthData();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!isAuthenticated()) {
      UserSession.instance.clear();
      return null;
    }
    try {
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUserData(user);
      UserSession.instance.setUser(user);
      return user;
    } on UnauthorizedException {
      UserSession.instance.clear();
      await _localDataSource.clearAuthData();
      return null;
    } catch (_) {
      // Offline fallback: load from local storage or memory
      final cachedUser = _localDataSource.getUserData();
      if (cachedUser != null) {
        UserSession.instance.setUser(cachedUser);
      }
      return cachedUser ?? UserSession.instance.currentUser;
    }
  }

  @override
  bool isAuthenticated() =>
      UserSession.instance.isAuthenticated || _localDataSource.isAuthenticated();

  @override
  Future<String> forgotPassword(String email) async {
    try {
      return await _remoteDataSource.forgotPassword(email);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(message: e.message);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      return await _remoteDataSource.resetPassword(resetToken, newPassword);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(message: e.message);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final response = await _remoteDataSource.refreshToken();
      final Map<String, dynamic> dataMap =
          (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;

      final token = dataMap['access_token'] as String? ?? '';
      if (token.isNotEmpty) {
        await _localDataSource.saveAccessToken(token);
        UserSession.instance.setToken(token);
      }
      return token;
    } on UnauthorizedException catch (e) {
      UserSession.instance.clear();
      await _localDataSource.clearAuthData();
      throw UnauthorizedFailure(message: e.message);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  }) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
        dateOfBirth: dateOfBirth,
        gender: gender,
        preferredLanguage: preferredLanguage,
        marketingOptIn: marketingOptIn,
      );

      // Persist to local storage and in-memory session singleton
      await _localDataSource.saveUserData(updatedUser);
      UserSession.instance.setUser(updatedUser);

      return updatedUser;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(message: e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
