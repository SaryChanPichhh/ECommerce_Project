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
            label: 'Email',
            hint: 'Enter your email',
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
              label: 'Password',
              hint: 'Enter your password',
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

          // Error message
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Login button
          Obx(
            () => AppButton(
              text: 'Login',
              onPressed: controller.login,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}
