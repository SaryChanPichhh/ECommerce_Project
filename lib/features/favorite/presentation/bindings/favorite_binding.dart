import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/usecases/get_favorites.dart';
import '../controllers/favorite_controller.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
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
