import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:final_project/app/controllers/localization_controller.dart';
import 'package:final_project/app/controllers/theme_controller.dart';
import 'package:final_project/core/localization/app_translations.dart';
import 'package:final_project/core/localization/langs/en_us.dart';
import 'package:final_project/core/localization/langs/km_kh.dart';
import 'package:final_project/core/storage/local_storage.dart';

class MockGetStorage extends Mock implements GetStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetStorage mockStorage;
  late Map<String, dynamic> memoryStore;
  late LocalStorage localStorage;

  setUp(() {
    Get.reset();
    memoryStore = {};
    mockStorage = MockGetStorage();

    when(() => mockStorage.read<bool>(any())).thenAnswer((inv) {
      final key = inv.positionalArguments[0] as String;
      return memoryStore[key] as bool?;
    });

    when(() => mockStorage.read<String>(any())).thenAnswer((inv) {
      final key = inv.positionalArguments[0] as String;
      return memoryStore[key] as String?;
    });

    when(() => mockStorage.write(any(), any())).thenAnswer((inv) async {
      final key = inv.positionalArguments[0] as String;
      final val = inv.positionalArguments[1];
      memoryStore[key] = val;
    });

    localStorage = LocalStorage(storage: mockStorage);
    Get.put<LocalStorage>(localStorage, permanent: true);
  });

  group('ThemeController Tests', () {
    test('initializes with default light mode when storage is empty', () {
      final themeCtrl = ThemeController(storage: localStorage);
      themeCtrl.onInit();

      expect(themeCtrl.isDark.value, isFalse);
    });

    test('initializes with dark mode when storage has isDarkMode true', () {
      memoryStore['is_dark_mode'] = true;
      final themeCtrl = ThemeController(storage: localStorage);
      themeCtrl.onInit();

      expect(themeCtrl.isDark.value, isTrue);
    });

    test('toggleTheme flips between light and dark mode and persists to storage', () {
      final themeCtrl = ThemeController(storage: localStorage);
      themeCtrl.onInit();

      expect(themeCtrl.isDark.value, isFalse);

      themeCtrl.toggleTheme();
      expect(themeCtrl.isDark.value, isTrue);
      expect(memoryStore['is_dark_mode'], isTrue);

      themeCtrl.toggleTheme();
      expect(themeCtrl.isDark.value, isFalse);
      expect(memoryStore['is_dark_mode'], isFalse);
    });

    test('setTheme explicitly sets dark mode and persists', () {
      final themeCtrl = ThemeController(storage: localStorage);
      themeCtrl.onInit();

      themeCtrl.setTheme(true);
      expect(themeCtrl.isDark.value, isTrue);
      expect(memoryStore['is_dark_mode'], isTrue);

      themeCtrl.setTheme(false);
      expect(themeCtrl.isDark.value, isFalse);
      expect(memoryStore['is_dark_mode'], isFalse);
    });
  });

  group('LocalizationController Tests', () {
    test('initializes with English when storage is empty', () {
      final locCtrl = LocalizationController(storage: localStorage);
      locCtrl.onInit();

      expect(locCtrl.currentLanguage.value, 'en');
      expect(locCtrl.isEnglish, isTrue);
      expect(locCtrl.isKhmer, isFalse);
      expect(locCtrl.currentLocale, const Locale('en', 'US'));
    });

    test('initializes with Khmer when storage has languageCode = km', () {
      memoryStore['language_code'] = 'km';
      final locCtrl = LocalizationController(storage: localStorage);
      locCtrl.onInit();

      expect(locCtrl.currentLanguage.value, 'km');
      expect(locCtrl.isKhmer, isTrue);
      expect(locCtrl.isEnglish, isFalse);
      expect(locCtrl.currentLocale, const Locale('km', 'KH'));
    });

    test('changeLanguage switches between English and Khmer and persists', () async {
      final locCtrl = LocalizationController(storage: localStorage);
      locCtrl.onInit();

      await locCtrl.changeLanguage('km');
      expect(locCtrl.currentLanguage.value, 'km');
      expect(locCtrl.isKhmer, isTrue);
      expect(locCtrl.currentLocale, const Locale('km', 'KH'));
      expect(memoryStore['language_code'], 'km');

      await locCtrl.changeLanguage('en');
      expect(locCtrl.currentLanguage.value, 'en');
      expect(locCtrl.isEnglish, isTrue);
      expect(locCtrl.currentLocale, const Locale('en', 'US'));
      expect(memoryStore['language_code'], 'en');
    });

    test('changeLanguage ignores invalid language codes', () async {
      final locCtrl = LocalizationController(storage: localStorage);
      locCtrl.onInit();

      await locCtrl.changeLanguage('fr');
      expect(locCtrl.currentLanguage.value, 'en');
      expect(memoryStore.containsKey('language_code'), isFalse);
    });
  });

  group('Translations Parity Tests', () {
    test('enUS and kmKH share the critical localization keys', () {
      final requiredKeys = [
        'home',
        'order',
        'search',
        'favorite',
        'setting',
        'language',
        'dark_mode',
        'light_mode',
        'english',
        'khmer',
        'general',
        'preference',
        'logout',
      ];

      for (final key in requiredKeys) {
        expect(enUS.containsKey(key), isTrue, reason: 'enUS missing key: $key');
        expect(kmKH.containsKey(key), isTrue, reason: 'kmKH missing key: $key');
      }
    });

    test('AppTranslations provides maps for both en_US and km_KH', () {
      final translations = AppTranslations();
      final keys = translations.keys;

      expect(keys.containsKey('en_US'), isTrue);
      expect(keys.containsKey('km_KH'), isTrue);
      expect(keys.containsKey('en'), isTrue);
      expect(keys.containsKey('km'), isTrue);
    });
  });
}
