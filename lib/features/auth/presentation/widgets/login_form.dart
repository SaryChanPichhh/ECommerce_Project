import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';

/// Login form widget.
class LoginForm extends GetView<LoginController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AppTextField(
            controller: controller.emailController,
            label: 'email'.tr,
            hint: 'enter_your_email'.tr,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: Validators.email,
          ),
          const SizedBox(height: AppDimensions.md),

          // Password field
          Obx(
            () => AppTextField(
              controller: controller.passwordController,
              label: 'password'.tr,
              hint: 'enter_your_password'.tr,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: Validators.password,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Error message alert banner
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Login button
          Obx(
            () => AppButton(
              text: 'login'.tr,
              onPressed: controller.login,
              isLoading: controller.isLoading.value,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('dont_have_account'.tr),
              TextButton(
                onPressed: () => Get.toNamed('/signup'),
                child: Text(
                  'sign_up'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
