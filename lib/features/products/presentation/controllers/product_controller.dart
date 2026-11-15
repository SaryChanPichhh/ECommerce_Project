import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';

class ProductController extends GetxController {
  final GetProductsUseCase _getProductsUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final GetCategoriesUseCase? _getCategoriesUseCase;

  ProductController({
    required GetProductsUseCase getProductsUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    GetCategoriesUseCase? getCategoriesUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _deleteProductUseCase = deleteProductUseCase,
        _getCategoriesUseCase = getCategoriesUseCase;

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> apiCategories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // View state & filters
  final RxBool isGridView = true.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedSort = 'default'.obs;
  final RxList<String> categories = <String>['All'].obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.isNotEmpty && args != 'All') {
      if (args.startsWith('cat-')) {
        selectedCategoryId.value = args;
      } else {
        selectedCategory.value = args;
        if (!categories.contains(args)) {
          categories.add(args);
        }
      }
    } else if (args is Map) {
      final argId = args['categoryId']?.toString() ?? args['id']?.toString();
      final argCat = args['category']?.toString() ?? args['name']?.toString();
      final argSearch = args['search']?.toString();
      if (argId != null && argId.isNotEmpty) {
        selectedCategoryId.value = argId;
      }
      if (argCat != null && argCat.isNotEmpty && argCat != 'All') {
        selectedCategory.value = argCat;
        if (!categories.contains(argCat)) {
          categories.add(argCat);
        }
      }
      if (argSearch != null && argSearch.isNotEmpty) {
        searchQuery.value = argSearch;
        searchController.text = argSearch;
      }
    }
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    await _loadCategories();
    await fetchProducts();
  }

  Future<void> _loadCategories() async {
    if (_getCategoriesUseCase == null) return;
    try {
      final result = await _getCategoriesUseCase();
      apiCategories.assignAll(result);

      final catSet = <String>{'All'};
      for (final c in result) {
        if (c.name.trim().isNotEmpty) {
          catSet.add(c.name.trim());
        }
        if (selectedCategoryId.value == c.id) {
          selectedCategory.value = c.name;
        } else if (selectedCategoryId.value.isEmpty &&
            selectedCategory.value != 'All' &&
            c.name.toLowerCase() == selectedCategory.value.toLowerCase()) {
          selectedCategoryId.value = c.id;
        }
      }
      categories.assignAll(catSet.toList());
    } catch (_) {}
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? categoryParam;
      if (selectedCategory.value != 'All') {
        categoryParam = selectedCategoryId.value.isNotEmpty
            ? selectedCategoryId.value
            : selectedCategory.value;
      } else if (selectedCategoryId.value.isNotEmpty) {
        categoryParam = selectedCategoryId.value;
      }

      final result = await _getProductsUseCase(
        limit: 50,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        category: categoryParam,
      );
      products.assignAll(result);

      if (apiCategories.isEmpty) {
        final catSet = <String>{'All'};
        for (final p in result) {
          if (p.category != null && p.category!.trim().isNotEmpty) {
            catSet.add(p.category!.trim());
          }
        }
        categories.assignAll(catSet.toList());
      }
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

    // 1. Filter locally only when products carry explicit category labels
    //    (backend ?category_id= already filters server-side even when list summary omits nested category).
    if (selectedCategory.value != 'All' && selectedCategoryId.value.isEmpty) {
      list = list.where((p) {
        return p.category == null ||
            p.category!.toLowerCase() ==
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
    if (category == 'All') {
      selectedCategoryId.value = '';
    } else {
      final matched = apiCategories.where(
        (c) => c.name.toLowerCase() == category.toLowerCase(),
      );
      selectedCategoryId.value = matched.isNotEmpty ? matched.first.id : '';
    }
    fetchProducts();
  }

  void setSort(String sort) {
    selectedSort.value = sort;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), fetchProducts);
  }

  void clearSearch() {
    _searchDebounce?.cancel();
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
