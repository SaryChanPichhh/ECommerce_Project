import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_form.dart';

/// Login page.
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / App icon
                Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.lg),

                // Title
                Text(
                  'Welcome Back',
                  style: AppTextStyles.h1.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),

                // Subtitle
                Text(
                  'Sign in to your account',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),

                // Login Form
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
