import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

class CategoryController extends GetxController {
  final GetProductsUseCase _getProductsUseCase;
  final GetCategoriesUseCase? _getCategoriesUseCase;

  CategoryController({
    required GetProductsUseCase getProductsUseCase,
    GetCategoriesUseCase? getCategoriesUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late String categoryName;
  String? categoryId;
  String? categoryImageUrl;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      categoryId = args['id']?.toString();
      categoryName = args['name']?.toString() ?? 'Category';
      categoryImageUrl = args['imageUrl']?.toString();
    } else if (args is String && args.isNotEmpty) {
      if (args.startsWith('cat-')) {
        categoryId = args;
        categoryName = 'Category';
      } else {
        categoryName = args;
      }
    } else {
      categoryName = 'Category';
    }
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? resolvedId = categoryId;
      if ((resolvedId == null || resolvedId.isEmpty) &&
          _getCategoriesUseCase != null) {
        try {
          final cats = await _getCategoriesUseCase();
          final matched = cats.where(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
          );
          if (matched.isNotEmpty) {
            resolvedId = matched.first.id;
            categoryId = resolvedId;
            categoryImageUrl ??= matched.first.imageUrl ?? matched.first.iconUrl;
          }
        } catch (_) {}
      }

      final result = await _getProductsUseCase(
        limit: 50,
        category: (resolvedId != null && resolvedId.isNotEmpty)
            ? resolvedId
            : categoryName,
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
