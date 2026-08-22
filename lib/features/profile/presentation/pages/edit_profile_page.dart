import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('edit_profile'.tr),
      ),
      body: Obx(() {
        final user = controller.user.value;
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            const SizedBox(height: AppDimensions.lg),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            TextFormField(
              initialValue: user?.name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              initialValue: user?.email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              initialValue: user?.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Changes'),
            ),
          ],
        );
      }),
    );
  }
}
