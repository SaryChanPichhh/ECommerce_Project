import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/network/interceptors/logging_interceptor.dart';
import '../../core/network/user_session.dart';
import '../../core/storage/local_storage.dart';
import '../../core/services/cloudflare_r2_service.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user.dart';
import '../controllers/localization_controller.dart';
import '../controllers/theme_controller.dart';

/// Initial binding that sets up global dependencies.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final localStorage = LocalStorage();
    Get.put(localStorage, permanent: true);

    // Initialize UserSession singleton from persisted storage
    final token = localStorage.getAccessToken();
    final refreshToken = localStorage.getRefreshToken();
    final userData = localStorage.getUserData();
    User? user;
    if (userData != null) {
      try {
        user = UserModel.fromJson(userData);
      } catch (_) {}
    }
    UserSession.instance.init(
      token: token,
      refreshToken: refreshToken,
      user: user,
    );

    final apiClient = ApiClient();
    apiClient.addInterceptors([
      AuthInterceptor(localStorage: Get.find<LocalStorage>()),
      LoggingInterceptor(),
    ]);
    Get.put(apiClient, permanent: true);

    // Cloudflare R2 storage service for uploading images (avatars, products, etc.)
    Get.put(CloudflareR2Service(), permanent: true);

    // Global localization controller — persists language choice (English / Khmer).
    Get.put(
      LocalizationController(storage: Get.find<LocalStorage>()),
      permanent: true,
    );

    // Global theme controller — persists dark/light mode preference.
    Get.put(
      ThemeController(storage: Get.find<LocalStorage>()),
      permanent: true,
    );
  }
}
