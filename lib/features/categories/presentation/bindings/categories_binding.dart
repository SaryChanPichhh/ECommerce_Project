import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoryRemoteDataSource>()) {
      Get.lazyPut<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(
        () => CategoryRepositoryImpl(
          remoteDataSource: Get.find<CategoryRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetCategoriesUseCase>()) {
      Get.lazyPut(
        () => GetCategoriesUseCase(repository: Get.find<CategoryRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CategoriesController>()) {
      Get.lazyPut(
        () => CategoriesController(
          getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
