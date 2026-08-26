import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';

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
    Get.changeThemeMode(saved ? ThemeMode.dark : ThemeMode.light);
  }

  /// Toggles between dark and light, persists the choice.
  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    _storage.saveDarkMode(isDark.value);
  }
}
