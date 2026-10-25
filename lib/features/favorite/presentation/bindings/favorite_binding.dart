import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../controllers/favorite_controller.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FavoriteRemoteDataSource>()) {
      Get.lazyPut<FavoriteRemoteDataSource>(
        () => FavoriteRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FavoriteRepositoryImpl>()) {
      Get.lazyPut<FavoriteRepositoryImpl>(
        () => FavoriteRepositoryImpl(
          remoteDataSource: Get.find<FavoriteRemoteDataSource>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FavoriteRepository>()) {
      Get.lazyPut<FavoriteRepository>(
        () => Get.isRegistered<FavoriteRepositoryImpl>()
            ? Get.find<FavoriteRepositoryImpl>()
            : FavoriteRepositoryImpl(
                remoteDataSource: Get.find<FavoriteRemoteDataSource>(),
              ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GetFavoritesUseCase>()) {
      Get.lazyPut(
        () => GetFavoritesUseCase(Get.find<FavoriteRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddFavoriteUseCase>()) {
      Get.lazyPut(
        () => AddFavoriteUseCase(Get.find<FavoriteRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RemoveFavoriteUseCase>()) {
      Get.lazyPut(
        () => RemoveFavoriteUseCase(Get.find<FavoriteRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FavoriteController>()) {
      Get.lazyPut(
        () => FavoriteController(
          getFavoritesUseCase: Get.find<GetFavoritesUseCase>(),
          addFavoriteUseCase: Get.find<AddFavoriteUseCase>(),
          removeFavoriteUseCase: Get.find<RemoveFavoriteUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
