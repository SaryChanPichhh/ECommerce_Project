import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../app/controllers/theme_controller.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('setting'.tr, style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoading();
        if (controller.errorMessage.value.isNotEmpty) {
          return AppError(
            message: controller.errorMessage.value,
            onRetry: controller.loadProfile,
          );
        }
        final user = controller.user.value;

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          physics: const BouncingScrollPhysics(),
          children: [
            // First block: User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Image.asset(
                      width: 100, // 2 * radius
                      height: 100,
                      'assets/images/profile.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Unknown User',
                        style: AppTextStyles.h4,
                      ),
                      if (user?.phone != null || user?.email != null)
                        const SizedBox(height: 4),
                      if (user?.phone != null)
                        Text(
                          user!.phone!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        )
                      else if (user?.email != null)
                        Text(
                          user?.email ?? '',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            // Second block: General
            Text('general'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.sm),
            _buildTile(Icons.person_outline, 'edit_profile'.tr, () => Get.toNamed('/profile/edit')),
            _buildTile(Icons.lock_outline, 'change_password'.tr, () => Get.toNamed('/profile/change-password')),
            _buildTile(Icons.notifications_outlined, 'notification'.tr, () => Get.toNamed('/profile/notification')),
            _buildTile(Icons.security_outlined, 'security'.tr, () {}),
            _buildTile(Icons.language_outlined, 'language'.tr, () => Get.toNamed('/profile/language')),

            // Dark Mode toggle — below Language
            Obx(() => _buildSwitchTile(
              icon: themeCtrl.isDark.value
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: 'dark_mode'.tr,
              value: themeCtrl.isDark.value,
              onChanged: (_) => themeCtrl.toggleTheme(),
            )),

            const SizedBox(height: AppDimensions.lg),

            // Third block: Preference
            Text('preference'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.sm),
            _buildTile(Icons.policy_outlined, 'legal_and_policies'.tr, () => Get.toNamed('/profile/legal-policies')),
            _buildTile(Icons.help_outline, 'help_and_support'.tr, () => Get.toNamed('/profile/help-support')),
            _buildTile(
              Icons.logout,
              'logout'.tr,
              controller.logout,
              color: AppColors.error,
            ),
            SizedBox(height: 150),
          ],
        );
      }),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = AppColors.primary,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      onTap: onTap,
    );
  }

  /// A ListTile variant with a [Switch] trailing instead of an arrow.
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
