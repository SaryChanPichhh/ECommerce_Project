import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_translations.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class App extends StatelessWidget {
  const App({super.key});

  /// -d chrome --web-port=10000 --web-browser-flag=--disable-web-security --web-browser-flag=--user-data-dir=C:/temp/flutter_chrome_dev
  @override
  Widget build(BuildContext context) {
    final storage = LocalStorage();
    final isDark = storage.isDarkMode();
    final langCode = storage.getLanguageCode();
    final initialLocale = langCode == 'km'
        ? const Locale('km', 'KH')
        : const Locale('en', 'US');

    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
      builder: DevicePreview.appBuilder,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
