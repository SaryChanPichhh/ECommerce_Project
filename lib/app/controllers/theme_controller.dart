import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_theme.dart';

/// Global controller for light / dark theme switching.
/// Persists the user's choice via [LocalStorage].
class ThemeController extends GetxController {
  final LocalStorage _storage;

  ThemeController({required LocalStorage storage}) : _storage = storage;

  /// `true` = dark mode, `false` = light mode.
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Restore persisted preference from local storage
    final saved = _storage.isDarkMode();
    isDark.value = saved;
  }

  /// Toggles between dark and light, persists the choice.
  void toggleTheme() {
    setTheme(!isDark.value);
  }

  /// Sets dark or light mode, updates both ThemeMode and ThemeData, and persists.
  void setTheme(bool dark) {
    isDark.value = dark;
    _storage.saveDarkMode(dark);
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    final themeData = dark ? AppTheme.dark : AppTheme.light;
    Get.changeThemeMode(mode);
    Get.changeTheme(themeData);
  }
}
