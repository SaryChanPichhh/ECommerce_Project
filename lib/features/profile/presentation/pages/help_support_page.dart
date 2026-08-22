import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('help_and_support'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text('FAQ 1: How do I change my password?'),
            const SizedBox(height: 4),
            const Text('Go to Settings > Change Password to update your credentials.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: AppDimensions.md),
            const Text('FAQ 2: How do I change the language?'),
            const SizedBox(height: 4),
            const Text('Go to Settings > Language and select your preferred language.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: AppDimensions.xl),
            const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.md),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('support@example.com'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('+855 12 345 678'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
