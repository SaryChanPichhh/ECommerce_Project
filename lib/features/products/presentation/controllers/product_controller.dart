import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';

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

  // View state & filters
  final RxBool isGridView = true.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedSort = 'default'.obs;
  final RxList<String> categories = <String>['All'].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _getProductsUseCase(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      products.assignAll(result);

      // Extract unique categories dynamically
      final catSet = <String>{'All'};
      for (final p in result) {
        if (p.category != null && p.category!.trim().isNotEmpty) {
          catSet.add(p.category!.trim());
        }
      }
      categories.assignAll(catSet.toList());
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    List<Product> list = products.toList();

    // 1. Filter by category
    if (selectedCategory.value != 'All') {
      list = list.where((p) {
        return p.category?.toLowerCase() ==
            selectedCategory.value.toLowerCase();
      }).toList();
    }

    // 2. Search query (client-side matching in addition to API)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.category?.toLowerCase().contains(query) ?? false) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 3. Sorting
    switch (selectedSort.value) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));
        break;
      case 'popular':
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'default':
      default:
        break;
    }

    return list;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSort(String sort) {
    selectedSort.value = sort;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchProducts();
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

  Future<void> refreshProducts() => fetchProducts();
}
