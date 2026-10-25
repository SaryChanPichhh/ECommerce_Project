import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if token exists
    final localStorage = Get.find<LocalStorage>();
    if (!localStorage.isAuthenticated()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null; // Proceed to the route
  }
}
