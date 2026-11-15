import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../categories/presentation/bindings/categories_binding.dart';
import '../../../products/data/datasources/product_remote_datasource.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/usecases/get_products.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(localStorage: Get.find<LocalStorage>()),
      fenix: true,
    );
    Get.lazyPut(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );

    // Products dependencies for Home page popular products
    if (!Get.isRegistered<ProductRemoteDataSource>()) {
      Get.lazyPut<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ProductRepositoryImpl>()) {
      Get.lazyPut(
        () => ProductRepositoryImpl(
          remoteDataSource: Get.find<ProductRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetProductsUseCase>()) {
      Get.lazyPut(
        () => GetProductsUseCase(repository: Get.find<ProductRepositoryImpl>()),
        fenix: true,
      );
    }

    CategoriesBinding().dependencies();

    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        getProductsUseCase: Get.find<GetProductsUseCase>(),
      ),
      fenix: true,
    );
  }
}
