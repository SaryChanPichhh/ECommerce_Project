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

import '../../features/favorite/data/datasources/favorite_remote_datasource.dart';
import '../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../features/favorite/domain/usecases/get_favorites.dart';
import '../../features/favorite/presentation/controllers/favorite_controller.dart';

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

    // Home controller
    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );

    // Order dependencies
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut(
      () => OrderRepositoryImpl(
        remoteDataSource: Get.find<OrderRemoteDataSource>(),
      ),
    );
    Get.lazyPut(
      () => GetOrdersUseCase(repository: Get.find<OrderRepositoryImpl>()),
    );
    Get.lazyPut(
      () => OrderController(
        getOrdersUseCase: Get.find<GetOrdersUseCase>(),
      ),
    );

    // Profile controller
    Get.lazyPut(
      () => ProfileController(
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
      ),
    );

    // Favorite dependencies
    Get.lazyPut<FavoriteRemoteDataSource>(
      () => FavoriteRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut(
      () => FavoriteRepositoryImpl(
        remoteDataSource: Get.find<FavoriteRemoteDataSource>(),
      ),
    );
    Get.lazyPut(
      () => GetFavoritesUseCase(Get.find<FavoriteRepositoryImpl>()),
    );
    Get.lazyPut(
      () => FavoriteController(
        getFavoritesUseCase: Get.find<GetFavoritesUseCase>(),
      ),
    );
  }
}
