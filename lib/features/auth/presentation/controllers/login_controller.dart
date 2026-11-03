import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/models/user_model.dart';
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
  final RxBool loginAsAdmin = false.obs;

  /// Toggle password visibility.
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void onInit() {
    super.onInit();
    _clearStaleSessionForRequiredLogin();
  }

  /// Ensure login is strictly required when entering the login screen.
  void _clearStaleSessionForRequiredLogin() {
    final localStorage = Get.isRegistered<LocalStorage>()
        ? Get.find<LocalStorage>()
        : LocalStorage();
    localStorage.clearAuthData();
    UserSession.instance.clear();
  }

  /// Execute login.
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = emailController.text.trim();
      final user = await _loginUseCase(
        email: email,
        password: passwordController.text,
      );

      Helpers.showSuccess('Login successful');

      final shouldSetAdminRole =
          loginAsAdmin.value || email.toLowerCase().contains('admin');
      final effectiveUser = (shouldSetAdminRole && user.role != 'admin')
          ? user.copyWith(role: 'admin')
          : user;

      final storage = Get.isRegistered<LocalStorage>()
          ? Get.find<LocalStorage>()
          : LocalStorage();
      await storage.saveUserData(UserModel.fromEntity(effectiveUser).toJson());
      UserSession.instance.setSession(
        token: UserSession.instance.accessToken ?? storage.getAccessToken() ?? '',
        user: effectiveUser,
      );

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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
