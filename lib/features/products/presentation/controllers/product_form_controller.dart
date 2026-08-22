import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/get_product.dart';

class ProductFormController extends GetxController {
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final GetProductUseCase _getProductUseCase;

  ProductFormController({
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required GetProductUseCase getProductUseCase,
  })  : _createProductUseCase = createProductUseCase,
        _updateProductUseCase = updateProductUseCase,
        _getProductUseCase = getProductUseCase;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final categoryController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Product> product = Rxn<Product>();

  bool get isEditing => product.value != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) {
      loadProduct(args);
    }
  }

  Future<void> loadProduct(String id) async {
    isLoading.value = true;
    try {
      final result = await _getProductUseCase(id);
      product.value = result;
      _populateForm(result);
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load product';
    } finally {
      isLoading.value = false;
    }
  }

  void _populateForm(Product p) {
    nameController.text = p.name;
    descriptionController.text = p.description ?? '';
    priceController.text = p.price.toString();
    quantityController.text = p.quantity.toString();
    categoryController.text = p.category ?? '';
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final productData = Product(
        id: product.value?.id ?? '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        price: double.tryParse(priceController.text) ?? 0.0,
        quantity: int.tryParse(quantityController.text) ?? 0,
        category: categoryController.text.trim().isNotEmpty
            ? categoryController.text.trim()
            : null,
      );

      if (isEditing) {
        await _updateProductUseCase(productData);
        Helpers.showSuccess('Product updated successfully');
      } else {
        await _createProductUseCase(productData);
        Helpers.showSuccess('Product created successfully');
      }

      Get.back(result: true);
    } on Failure catch (e) {
      errorMessage.value = e.message;
      Helpers.showError(e.message);
    } catch (e) {
      errorMessage.value = 'Failed to save product';
      Helpers.showError('Failed to save product');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    categoryController.dispose();
    super.onClose();
  }
}
