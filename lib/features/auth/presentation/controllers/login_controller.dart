import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/usecases/login.dart';

/// Controller for the login page.
class LoginController extends GetxController {
  final LoginUseCase _loginUseCase;

  LoginController({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  /// Toggle password visibility.
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Execute login.
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // await _loginUseCase(
      //   email: emailController.text.trim(),
      //   password: passwordController.text,
      // );

      Helpers.showSuccess('Login successful');
      Get.offAllNamed('/main');
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
