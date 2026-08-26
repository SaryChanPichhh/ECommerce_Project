import 'package:device_preview/device_preview.dart';
import 'package:final_project/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_translations.dart';
import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: const Locale('km', 'KH'),
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
      builder: DevicePreview.appBuilder,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Reactively driven by ThemeController; falls back to system if not yet loaded.
      themeMode: Get.isRegistered<ThemeController>()
          ? (Get.find<ThemeController>().isDark.value
              ? ThemeMode.dark
              : ThemeMode.light)
          : ThemeMode.system,
      initialRoute: AppRoutes.main,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
