import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bindings/auth_binding.dart';
import '../controllers/signup_controller.dart';

class SignupPage extends GetView<SignupController> {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SignupController>()) {
      AuthBinding().dependencies();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Gradient Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'create_account'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select Customer or Admin role to register',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Card
            Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Selector Segmented Control (Customer vs Administrator)
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(
                              bottom: AppDimensions.md,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.setRole('customer'),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: controller.selectedRole.value ==
                                                'customer'
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color:
                                                controller.selectedRole.value ==
                                                        'customer'
                                                    ? Colors.white
                                                    : const Color(0xFF475569),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'customer_account'.tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.5,
                                                color: controller.selectedRole
                                                            .value ==
                                                        'customer'
                                                    ? Colors.white
                                                    : const Color(0xFF334155),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.setRole('admin'),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: controller.selectedRole.value ==
                                                'admin'
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.admin_panel_settings_outlined,
                                            size: 16,
                                            color:
                                                controller.selectedRole.value ==
                                                        'admin'
                                                    ? Colors.white
                                                    : const Color(0xFF475569),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'admin_account'.tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.5,
                                                color: controller.selectedRole
                                                            .value ==
                                                        'admin'
                                                    ? Colors.white
                                                    : const Color(0xFF334155),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller:
                                          controller.firstNameController,
                                      label: 'first_name'.tr,
                                      hint: 'enter_first_name'.tr,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppTextField(
                                      controller: controller.lastNameController,
                                      label: 'last_name'.tr,
                                      hint: 'enter_last_name'.tr,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              AppTextField(
                                controller: controller.emailController,
                                label: 'email'.tr,
                                hint: 'enter_your_email'.tr,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: Validators.email,
                              ),
                              const SizedBox(height: 12),

                              AppTextField(
                                controller: controller.phoneController,
                                label: 'phone'.tr,
                                hint: 'enter_your_phone'.tr,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                              const SizedBox(height: 12),

                              Obx(
                                () => AppTextField(
                                  controller: controller.passwordController,
                                  label: 'password'.tr,
                                  hint: 'enter_your_password'.tr,
                                  obscureText: controller.obscurePassword.value,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                  validator: Validators.password,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Obx(
                                () => AppTextField(
                                  controller:
                                      controller.confirmPasswordController,
                                  label: 'confirm_password'.tr,
                                  hint: 'enter_your_confirm_password'.tr,
                                  obscureText:
                                      controller.obscureConfirmPassword.value,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureConfirmPassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: controller
                                        .toggleConfirmPasswordVisibility,
                                  ),
                                  validator: (value) =>
                                      Validators.confirmPassword(
                                    value,
                                    controller.passwordController.text,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Admin Secret Key field
                              Obx(() {
                                if (!controller.isAdmin) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppTextField(
                                        controller:
                                            controller.adminSecretController,
                                        label: 'admin_secret_key'.tr,
                                        hint: 'enter_admin_secret'.tr,
                                        obscureText: true,
                                        prefixIcon: const Icon(
                                          Icons.security_outlined,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'ℹ️ Default admin key: AdminSecret123!',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF1D4ED8),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Error message
                              Obx(() {
                                if (controller.errorMessage.value.isNotEmpty) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),

                              Obx(
                                () => AppButton(
                                  text: 'sign_up'.tr,
                                  onPressed: controller.signup,
                                  isLoading: controller.isLoading.value,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'already_have_account'.tr,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.offNamed('/login'),
                                    child: Text(
                                      'login'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
