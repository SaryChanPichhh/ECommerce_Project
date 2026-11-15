import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Scaffold(
      appBar: AppBar(
        title: Text('setting'.tr, style: AppTextStyles.h3),
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
            // User Header Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: ClipOval(
                      child: (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? AppNetworkImage(
                              imageUrl: user.avatar,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorWidget: Image.asset(
                                'assets/images/profile.jpg',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person_rounded,
                                  size: 34,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Image.asset(
                              'assets/images/profile.jpg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person_rounded,
                                size: 34,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.name != null && user!.name.isNotEmpty)
                              ? user.name
                              : 'unknown_user'.tr,
                          style: AppTextStyles.h4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.phone != null &&
                            user!.phone!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.phone!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                        ] else if (user?.email != null &&
                            user!.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'edit_profile'.tr,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.profileEdit),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // General Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: AppDimensions.sm),
              child: Text('general'.tr, style: AppTextStyles.h4),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
                ),
              ),
              child: Column(
                children: [
                  _buildTile(
                    context,
                    Icons.person_outline_rounded,
                    'edit_profile'.tr,
                    () => Get.toNamed(AppRoutes.profileEdit),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.lock_outline_rounded,
                    'change_password'.tr,
                    () => Get.toNamed(AppRoutes.profileChangePassword),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.notifications_outlined,
                    'notification'.tr,
                    () => Get.toNamed(AppRoutes.profileNotification),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.security_outlined,
                    'security'.tr,
                    () => Helpers.showSuccess('security_notice'.tr),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.language_outlined,
                    'language'.tr,
                    () => Get.toNamed(AppRoutes.profileLanguage),
                  ),
                  const Divider(height: 1, indent: 56),
                  Obx(() => _buildSwitchTile(
                        context,
                        icon: themeCtrl.isDark.value
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        title: 'dark_mode'.tr,
                        value: themeCtrl.isDark.value,
                        onChanged: (_) => themeCtrl.toggleTheme(),
                      )),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Preference Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: AppDimensions.sm),
              child: Text('preference'.tr, style: AppTextStyles.h4),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
                ),
              ),
              child: Column(
                children: [
                  _buildTile(
                    context,
                    Icons.policy_outlined,
                    'legal_and_policies'.tr,
                    () => Get.toNamed(AppRoutes.profileLegalPolicies),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.help_outline_rounded,
                    'help_and_support'.tr,
                    () => Get.toNamed(AppRoutes.profileHelpSupport),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildTile(
                    context,
                    Icons.logout_rounded,
                    'logout'.tr,
                    controller.logout,
                    color: AppColors.error,
                    showDividerArrow: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),
          ],
        );
      }),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = AppColors.primary,
    bool showDividerArrow = true,
  }) {
    final isDanger = color == AppColors.error;
    final secondaryColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDanger ? AppColors.error : null,
          fontWeight: isDanger ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: showDividerArrow
          ? Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: secondaryColor,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
