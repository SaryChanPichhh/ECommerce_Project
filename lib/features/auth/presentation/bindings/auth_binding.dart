import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/get_current_user.dart';
import '../controllers/login_controller.dart';

/// Binding for authentication feature.
/// Sets up dependency injection for auth-related classes.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(localStorage: Get.find<LocalStorage>()),
    );

    // Repository
    Get.lazyPut(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // Use cases
    Get.lazyPut(
      () => LoginUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut(
      () => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut(
      () => LoginController(loginUseCase: Get.find<LoginUseCase>()),
    );
  }
}
