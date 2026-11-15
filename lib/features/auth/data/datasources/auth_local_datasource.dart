import '../../../../core/storage/local_storage.dart';
import '../models/user_model.dart';

/// Local data source for authentication.
/// Manages token and user data persistence.
abstract class AuthLocalDataSource {
  String? getAccessToken();
  Future<void> saveAccessToken(String token);
  String? getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> saveUserData(UserModel user);
  UserModel? getUserData();
  Future<void> clearAuthData();
  bool isAuthenticated();
}

/// Implementation of [AuthLocalDataSource].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage _localStorage;

  AuthLocalDataSourceImpl({required LocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  String? getAccessToken() => _localStorage.getAccessToken();

  @override
  Future<void> saveAccessToken(String token) =>
      _localStorage.saveAccessToken(token);

  @override
  String? getRefreshToken() => _localStorage.getRefreshToken();

  @override
  Future<void> saveRefreshToken(String token) =>
      _localStorage.saveRefreshToken(token);

  @override
  Future<void> saveUserData(UserModel user) =>
      _localStorage.saveUserData(user.toJson());

  @override
  UserModel? getUserData() {
    final data = _localStorage.getUserData();
    if (data != null) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await _localStorage.clearAuthData();
  }

  @override
  bool isAuthenticated() => _localStorage.isAuthenticated();
}
