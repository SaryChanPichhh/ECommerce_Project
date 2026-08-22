import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(localStorage: Get.find<LocalStorage>()),
    );
    Get.lazyPut(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );
    Get.lazyPut(
      () => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );
  }
}
