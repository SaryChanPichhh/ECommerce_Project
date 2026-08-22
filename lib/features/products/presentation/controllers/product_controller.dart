import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/delete_product.dart';

class ProductController extends GetxController {
  final GetProductsUseCase _getProductsUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductController({
    required GetProductsUseCase getProductsUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _deleteProductUseCase = deleteProductUseCase;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _getProductsUseCase(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      products.assignAll(result);
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    final confirmed = await AppDialog.showConfirm(
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product?',
      confirmText: 'Delete',
      isDanger: true,
    );

    if (!confirmed) return;

    try {
      await _deleteProductUseCase(id);
      products.removeWhere((p) => p.id == id);
      Helpers.showSuccess('Product deleted successfully');
    } on Failure catch (e) {
      Helpers.showError(e.message);
    } catch (e) {
      Helpers.showError('Failed to delete product');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  Future<void> refreshProducts() => fetchProducts();
}
