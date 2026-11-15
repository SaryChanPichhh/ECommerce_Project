import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

/// Centralized local storage wrapper.
/// Controllers should never access GetStorage directly.
class LocalStorage {
  final GetStorage _storage;

  LocalStorage({GetStorage? storage}) : _storage = storage ?? GetStorage();

  // --- Token Management ---

  /// Get the stored access token.
  String? getAccessToken() => _storage.read<String>(StorageKeys.accessToken);

  /// Save the access token.
  Future<void> saveAccessToken(String token) =>
      _storage.write(StorageKeys.accessToken, token);

  /// Get the stored refresh token.
  String? getRefreshToken() => _storage.read<String>(StorageKeys.refreshToken);

  /// Save the refresh token.
  Future<void> saveRefreshToken(String token) =>
      _storage.write(StorageKeys.refreshToken, token);

  /// Clear all authentication tokens.
  Future<void> clearTokens() async {
    await _storage.remove(StorageKeys.accessToken);
    await _storage.remove(StorageKeys.refreshToken);
  }

  /// Clear all authentication tokens and user information.
  Future<void> clearAuthData() async {
    await clearTokens();
    await _storage.remove(StorageKeys.userId);
    await _storage.remove(StorageKeys.userData);
  }

  // --- User Data ---

  /// Get the stored user ID.
  String? getUserId() => _storage.read<String>(StorageKeys.userId);

  /// Save the user ID.
  Future<void> saveUserId(String id) =>
      _storage.write(StorageKeys.userId, id);

  /// Get the stored user data as a Map.
  Map<String, dynamic>? getUserData() {
    final raw = _storage.read(StorageKeys.userData);
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  /// Save user data as a Map.
  Future<void> saveUserData(Map<String, dynamic> data) =>
      _storage.write(StorageKeys.userData, data);

  // --- Preferences ---

  /// Check if dark mode is enabled.
  bool isDarkMode() => _storage.read<bool>(StorageKeys.isDarkMode) ?? false;

  /// Save dark mode preference.
  Future<void> saveDarkMode(bool value) =>
      _storage.write(StorageKeys.isDarkMode, value);

  /// Get the current language code.
  String getLanguageCode() =>
      _storage.read<String>(StorageKeys.languageCode) ?? 'en';

  /// Save the language code.
  Future<void> saveLanguageCode(String code) =>
      _storage.write(StorageKeys.languageCode, code);

  /// Check if this is the first app launch.
  bool isFirstLaunch() =>
      _storage.read<bool>(StorageKeys.isFirstLaunch) ?? true;

  /// Mark that the app has been launched before.
  Future<void> setFirstLaunchDone() =>
      _storage.write(StorageKeys.isFirstLaunch, false);

  // --- Business Preferences ---

  /// Get the selected branch.
  String? getSelectedBranch() =>
      _storage.read<String>(StorageKeys.selectedBranch);

  /// Save the selected branch.
  Future<void> saveSelectedBranch(String branch) =>
      _storage.write(StorageKeys.selectedBranch, branch);

  /// Get the selected warehouse.
  String? getSelectedWarehouse() =>
      _storage.read<String>(StorageKeys.selectedWarehouse);

  /// Save the selected warehouse.
  Future<void> saveSelectedWarehouse(String warehouse) =>
      _storage.write(StorageKeys.selectedWarehouse, warehouse);

  // --- Search History ---
  List<String> getSearchHistory() {
    final history = _storage.read<List<dynamic>>(StorageKeys.searchHistory);
    return history?.map((e) => e.toString()).toList() ?? [];
  }

  Future<void> saveSearchHistory(List<String> history) =>
      _storage.write(StorageKeys.searchHistory, history);

  // --- General ---

  /// Check if user is authenticated (has access token).
  bool isAuthenticated() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data.
  Future<void> clearAll() => _storage.erase();
}
