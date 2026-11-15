import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/cloudflare_r2_service.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../../../categories/data/repositories/category_repository_impl.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_product_variants.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../controllers/product_controller.dart';
import '../controllers/product_form_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut(
      () => ProductRepositoryImpl(
        remoteDataSource: Get.find<ProductRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => GetProductsUseCase(repository: Get.find<ProductRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetProductVariantsUseCase(
        repository: Get.find<ProductRepositoryImpl>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => CreateProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => UpdateProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => DeleteProductUseCase(repository: Get.find<ProductRepositoryImpl>()),
      fenix: true,
    );

    // Categories dependencies for category dropdown in ProductForm
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

    Get.lazyPut(
      () => ProductController(
        getProductsUseCase: Get.find<GetProductsUseCase>(),
        deleteProductUseCase: Get.find<DeleteProductUseCase>(),
        getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ProductFormController(
        createProductUseCase: Get.find<CreateProductUseCase>(),
        updateProductUseCase: Get.find<UpdateProductUseCase>(),
        getProductUseCase: Get.find<GetProductUseCase>(),
        getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
        r2Service: Get.find<CloudflareR2Service>(),
      ),
      fenix: true,
    );
  }
}
