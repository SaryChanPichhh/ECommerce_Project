import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

class CategoriesController extends GetxController {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesController({required GetCategoriesUseCase getCategoriesUseCase})
      : _getCategoriesUseCase = getCategoriesUseCase;

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({String? parentId}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCategoriesUseCase(parentId: parentId);
      categories.assignAll(result);
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load categories';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String id) {
    if (selectedCategoryId.value == id) {
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = id;
    }
  }
}
