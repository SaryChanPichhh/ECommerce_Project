import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../controllers/main_nav_controller.dart';

import '../../features/cart/presentation/bindings/cart_binding.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/presentation/bindings/categories_binding.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/favorite/presentation/bindings/favorite_binding.dart';
import '../../features/search/presentation/controllers/search_catalog_controller.dart';

/// Binding for the main navigation page.
/// Registers all controllers needed by the bottom nav tabs.
class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    // Main navigation controller
    Get.lazyPut(() => MainNavController());

    // Auth dependencies (needed by Home & Profile)
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

    // Products dependencies (needed by Home)
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

    // Home controller
    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        getProductsUseCase: Get.find<GetProductsUseCase>(),
      ),
      fenix: true,
    );

    // Order dependencies
    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      Get.lazyPut<OrderRemoteDataSource>(
        () => OrderRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderRepositoryImpl>()) {
      Get.lazyPut(
        () => OrderRepositoryImpl(
          remoteDataSource: Get.find<OrderRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOrdersUseCase>()) {
      Get.lazyPut(
        () => GetOrdersUseCase(repository: Get.find<OrderRepositoryImpl>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut(
        () => OrderController(
          getOrdersUseCase: Get.find<GetOrdersUseCase>(),
        ),
        fenix: true,
      );
    }

    // Profile controller
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(
        () => ProfileController(
          getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
          logoutUseCase: Get.find<LogoutUseCase>(),
        ),
        fenix: true,
      );
    }

    // Categories, Search, Cart, and Favorite dependencies (preserve Add/Remove usecases)
    CategoriesBinding().dependencies();
    if (!Get.isRegistered<SearchCatalogController>()) {
      Get.lazyPut(
        () => SearchCatalogController(
          getProductsUseCase: Get.find<GetProductsUseCase>(),
          getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
        ),
        fenix: true,
      );
    }
    CartBinding().dependencies();
    FavoriteBinding().dependencies();
  }
}
