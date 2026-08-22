import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('change_password'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: [
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppDimensions.buttonHeight)),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
