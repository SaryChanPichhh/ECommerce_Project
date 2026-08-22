import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';

class LegalPoliciesPage extends StatelessWidget {
  const LegalPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('legal_and_policies'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Text(
          '1. Terms and Conditions\n\n'
          'By using this application, you agree to our terms and conditions. '
          'We reserve the right to update these terms at any time.\n\n'
          '2. Privacy Policy\n\n'
          'We value your privacy. Your data is stored securely and will not be shared '
          'with third parties without your explicit consent.\n\n'
          '3. Data Usage\n\n'
          'We collect minimal data required to provide you with the best experience. '
          'Please review our full privacy policy on our website for more details.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
