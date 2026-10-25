import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

class CategoryController extends GetxController {
  final GetProductsUseCase _getProductsUseCase;
  
  CategoryController({required GetProductsUseCase getProductsUseCase})
      : _getProductsUseCase = getProductsUseCase;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  late String categoryName;

  @override
  void onInit() {
    super.onInit();
    categoryName = Get.arguments as String? ?? 'Category';
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _getProductsUseCase(
        category: categoryName,
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
}
