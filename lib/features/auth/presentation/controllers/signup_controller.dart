import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/usecases/register.dart';

/// Controller for the signup/registration page with Customer & Admin support.
class SignupController extends GetxController {
  final RegisterUseCase _registerUseCase;

  SignupController({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase;

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final adminSecretController = TextEditingController();

  /// Role selection: 'customer' or 'admin'
  final RxString selectedRole = 'customer'.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAdmin => selectedRole.value == 'admin';

  void setRole(String role) {
    selectedRole.value = role;
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> signup() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) return;

    // Validate admin secret key if registering as Administrator
    if (isAdmin) {
      final secret = adminSecretController.text.trim();
      const validSecrets = ['AdminSecret123!', 'admin', 'setec_admin'];
      if (secret.isNotEmpty && !validSecrets.contains(secret)) {
        errorMessage.value = 'Invalid Admin security key. Use: AdminSecret123!';
        Helpers.showError(errorMessage.value);
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _registerUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim().isNotEmpty
            ? firstNameController.text.trim()
            : null,
        lastName: lastNameController.text.trim().isNotEmpty
            ? lastNameController.text.trim()
            : null,
        phoneNumber: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        role: selectedRole.value,
      );

      if (user.role == 'admin') {
        Helpers.showSuccess('admin_registered_successfully'.tr);
      } else {
        Helpers.showSuccess('Account created successfully!');
      }
      Get.offAllNamed(AppRoutes.main);
    } on Failure catch (e) {
      errorMessage.value = e.message;
      Helpers.showError(e.message);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Helpers.showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    adminSecretController.dispose();
    super.onClose();
  }
}
