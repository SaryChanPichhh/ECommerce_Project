import '../../features/auth/domain/entities/user.dart';
import '../utils/jwt_utils.dart';

/// Singleton class for managing user session state in memory.
/// Stores the active [accessToken], [refreshToken], and [currentUser] info.
class UserSession {
  // Private constructor
  UserSession._internal();

  // Static singleton instance
  static final UserSession _instance = UserSession._internal();

  /// Global access to the singleton instance.
  static UserSession get instance => _instance;

  String? _accessToken;
  String? _refreshToken;
  User? _currentUser;

  /// Get active access token.
  String? get accessToken => _accessToken;

  /// Get active refresh token.
  String? get refreshToken => _refreshToken;

  /// Get currently authenticated user info.
  User? get currentUser => _currentUser;

  /// Check if the user is currently authenticated with a valid, non-expired token.
  bool get isAuthenticated {
    if (_accessToken == null || _accessToken!.trim().isEmpty) {
      return false;
    }
    if (JwtUtils.isExpired(_accessToken)) {
      clear();
      return false;
    }
    return true;
  }

  /// Initialize or restore session (e.g. from local storage on app start).
  void init({
    String? token,
    String? refreshToken,
    User? user,
  }) {
    _accessToken = token;
    _refreshToken = refreshToken;
    _currentUser = user;
  }

  /// Assign a new access token to the singleton.
  void setToken(String? token) {
    _accessToken = token;
  }

  /// Assign or update current user info.
  void setUser(User? user) {
    _currentUser = user;
  }

  /// Set the full session after login or registration.
  void setSession({
    required String token,
    String? refreshToken,
    User? user,
  }) {
    _accessToken = token;
    _refreshToken = refreshToken;
    _currentUser = user;
  }

  /// Retrieve current user info.
  User? getUserInfo() => _currentUser;

  /// Clear the session on logout or when the token is invalidated.
  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }
}
