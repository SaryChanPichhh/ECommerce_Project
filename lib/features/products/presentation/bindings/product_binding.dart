import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../controllers/product_controller.dart';
import '../controllers/product_form_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );

    Get.lazyPut(
      () => ProductRepositoryImpl(
        remoteDataSource: Get.find<ProductRemoteDataSource>(),
      ),
    );

    Get.lazyPut(
      () => GetProductsUseCase(repository: Get.find<ProductRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
    );
    Get.lazyPut(
      () => CreateProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
    );
    Get.lazyPut(
      () => UpdateProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
    );
    Get.lazyPut(
      () => DeleteProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
    );

    Get.lazyPut(
      () => ProductController(
        getProductsUseCase: Get.find<GetProductsUseCase>(),
        deleteProductUseCase: Get.find<DeleteProductUseCase>(),
      ),
    );

    Get.lazyPut(
      () => ProductFormController(
        createProductUseCase: Get.find<CreateProductUseCase>(),
        updateProductUseCase: Get.find<UpdateProductUseCase>(),
        getProductUseCase: Get.find<GetProductUseCase>(),
      ),
    );
  }
}
