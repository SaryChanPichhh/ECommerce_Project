import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if token exists in local-storage and is not expired
    final localStorage = Get.isRegistered<LocalStorage>()
        ? Get.find<LocalStorage>()
        : LocalStorage();

    // If local-storage does not have token or it is expired, user must login
    if (!localStorage.isAuthenticated()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null; // Proceed to the route
  }
}
