import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';

/// Global controller managing app localization (Khmer & English).
/// Persists user choice via [LocalStorage].
class LocalizationController extends GetxController {
  final LocalStorage _storage;

  LocalizationController({required LocalStorage storage}) : _storage = storage;

  /// Current language code: 'en' or 'km'
  final RxString currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    final savedCode = _storage.getLanguageCode();
    currentLanguage.value = (savedCode == 'km') ? 'km' : 'en';
  }

  /// Returns true if the active language is Khmer.
  bool get isKhmer => currentLanguage.value == 'km';

  /// Returns true if the active language is English.
  bool get isEnglish => currentLanguage.value == 'en';

  /// Returns the corresponding [Locale] for the current language.
  Locale get currentLocale => getLocale(currentLanguage.value);

  /// Helper to convert language code to [Locale].
  Locale getLocale(String langCode) {
    if (langCode == 'km') {
      return const Locale('km', 'KH');
    }
    return const Locale('en', 'US');
  }

  /// Changes the application language, saves preference to [LocalStorage],
  /// and notifies GetX to update the active locale.
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'km') return;

    currentLanguage.value = languageCode;
    _storage.saveLanguageCode(languageCode);

    final newLocale = getLocale(languageCode);
    if (Get.context != null) {
      await Get.updateLocale(newLocale);
    }
  }
}
