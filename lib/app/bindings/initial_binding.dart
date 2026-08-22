import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/network/interceptors/logging_interceptor.dart';
import '../../core/storage/local_storage.dart';

/// Initial binding that sets up global dependencies.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocalStorage(), permanent: true);

    final apiClient = ApiClient();
    apiClient.addInterceptors([
      AuthInterceptor(localStorage: Get.find<LocalStorage>()),
      LoggingInterceptor(),
    ]);
    Get.put(apiClient, permanent: true);
  }
}
