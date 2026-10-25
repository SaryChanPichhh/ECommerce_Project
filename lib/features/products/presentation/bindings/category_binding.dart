import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/get_products.dart';
import '../controllers/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetProductsUseCase>()) {
      if (!Get.isRegistered<ProductRemoteDataSource>()) {
        Get.lazyPut<ProductRemoteDataSource>(
          () => ProductRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
        );
      }
      if (!Get.isRegistered<ProductRepositoryImpl>()) {
        Get.lazyPut(
          () => ProductRepositoryImpl(
            remoteDataSource: Get.find<ProductRemoteDataSource>(),
          ),
        );
      }
      Get.lazyPut(
        () => GetProductsUseCase(repository: Get.find<ProductRepositoryImpl>()),
      );
    }
    
    Get.lazyPut(
      () => CategoryController(
        getProductsUseCase: Get.find<GetProductsUseCase>(),
      ),
    );
  }
}
