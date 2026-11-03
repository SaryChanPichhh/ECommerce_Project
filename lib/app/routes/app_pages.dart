import 'package:get/get.dart';
import '../pages/splash_page.dart';
import '../middlewares/auth_middleware.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/admin/presentation/bindings/admin_dashboard_binding.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import 'app_routes.dart';

/// Application pages configuration (Admin-Dashboard branch).
class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
