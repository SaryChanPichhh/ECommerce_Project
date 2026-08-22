import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale?.languageCode ?? 'en';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('language'.tr),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            trailing: currentLocale == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () => Get.updateLocale(const Locale('en', 'US')),
          ),
          ListTile(
            title: const Text('ខ្មែរ (Khmer)'),
            trailing: currentLocale == 'km' ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () => Get.updateLocale(const Locale('km', 'KH')),
          ),
        ],
      ),
    );
  }
}
