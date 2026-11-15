import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/presentation/bindings/categories_binding.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/get_products.dart';
import '../controllers/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    CategoriesBinding().dependencies();

    if (!Get.isRegistered<GetProductsUseCase>()) {
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
      Get.lazyPut(
        () => GetProductsUseCase(repository: Get.find<ProductRepositoryImpl>()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => CategoryController(
        getProductsUseCase: Get.find<GetProductsUseCase>(),
        getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
      ),
    );
  }
}
