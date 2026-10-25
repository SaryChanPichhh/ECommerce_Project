import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/cloudflare_r2_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/update_product.dart';

class ProductFormController extends GetxController {
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final GetProductUseCase _getProductUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CloudflareR2Service _r2Service;

  ProductFormController({
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required GetProductUseCase getProductUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required CloudflareR2Service r2Service,
  })  : _createProductUseCase = createProductUseCase,
        _updateProductUseCase = updateProductUseCase,
        _getProductUseCase = getProductUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _r2Service = r2Service;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final categoryController = TextEditingController();

  final RxString imageUrl = ''.obs;
  final Rxn<Uint8List> localImageBytes = Rxn<Uint8List>();
  final RxBool isUploadingImage = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Product> product = Rxn<Product>();

  // Categories fetched from /api/v1/public/categories/
  final RxList<Category> availableCategories = <Category>[].obs;
  final Rxn<Category> selectedCategory = Rxn<Category>();
  final RxBool isLoadingCategories = false.obs;

  final ImagePicker _picker = ImagePicker();

  bool get isEditing => product.value != null;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    final args = Get.arguments;
    if (args != null && args is String) {
      loadProduct(args);
    }
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final cats = await _getCategoriesUseCase();
      availableCategories.assignAll(cats);
      _matchCategoryWithSelection();
    } catch (_) {
      if (availableCategories.isEmpty) {
        availableCategories.assignAll(const [
          Category(id: 'cat-000001', name: 'Consumer Electronics'),
          Category(id: 'cat-000004', name: 'Fashion & Apparel'),
          Category(id: 'cat-000002', name: 'Smartphones'),
          Category(id: 'cat-000003', name: 'Laptops'),
        ]);
        _matchCategoryWithSelection();
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void _matchCategoryWithSelection() {
    if (selectedCategory.value != null || availableCategories.isEmpty) return;
    final currentCat = categoryController.text.trim();
    if (currentCat.isEmpty) return;

    for (final cat in availableCategories) {
      if (cat.name.toLowerCase() == currentCat.toLowerCase() ||
          cat.id == currentCat) {
        selectedCategory.value = cat;
        categoryController.text = cat.name;
        break;
      }
    }
  }

  void onCategorySelected(Category cat) {
    selectedCategory.value = cat;
    categoryController.text = cat.name;
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
    imageUrl.value = p.imageUrl ?? '';
    _matchCategoryWithSelection();
  }

  /// Pick an image from camera or gallery and upload directly to Cloudflare R2
  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      // Instantly provide local preview so image is displayed immediately
      localImageBytes.value = bytes;

      isUploadingImage.value = true;
      AppDialog.showLoading(message: 'Uploading image to Cloudflare R2...');

      final uploadedUrl = await _r2Service.uploadProductImage(
        bytes: bytes,
        fileName: pickedFile.name,
        contentType: _getContentType(pickedFile.name),
      );

      imageUrl.value = uploadedUrl;
      AppDialog.hideLoading();
      Helpers.showSuccess('Product image uploaded successfully');
    } catch (e) {
      AppDialog.hideLoading();
      Helpers.showError('failed_to_upload_image'.tr);
    } finally {
      isUploadingImage.value = false;
    }
  }

  String _getContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
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
            : selectedCategory.value?.name,
        categoryId: selectedCategory.value?.id,
        imageUrl: imageUrl.value.isNotEmpty ? imageUrl.value : null,
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
