import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository].
/// Converts exceptions from data sources into domain-level failures.
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

      // Extract token and user data from response
      final token = response['token'] as String? ??
          response['access_token'] as String? ??
          '';
      final refreshToken = response['refresh_token'] as String?;
      final userData = response['user'] as Map<String, dynamic>? ?? response;

      // Save tokens
      await _localDataSource.saveAccessToken(token);
      if (refreshToken != null) {
        await _localDataSource.saveRefreshToken(refreshToken);
      }

      // Save user data
      final user = UserModel.fromJson(userData);
      await _localDataSource.saveUserData(user);

      return user;
    } on UnauthorizedException {
      throw const UnauthorizedFailure(message: 'Invalid email or password');
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
      // Even if the API call fails, clear local data
    } finally {
      await _localDataSource.clearAuthData();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // First try to get from remote
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUserData(user);
      return user;
    } on UnauthorizedException {
      await _localDataSource.clearAuthData();
      return null;
    } catch (_) {
      // Fallback to local data
      return _localDataSource.getUserData();
    }
  }

  @override
  bool isAuthenticated() => _localDataSource.isAuthenticated();
}
