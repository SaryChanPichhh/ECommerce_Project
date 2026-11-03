import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminDashboardController>()) {
      Get.put<AdminDashboardController>(
        AdminDashboardController(),
        permanent: true,
      );
    }
  }
}
