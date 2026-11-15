import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/usecases/get_products.dart';

/// Controller for the bottom-navigation Search tab.
/// Follows Clean Architecture by delegating data fetching to domain use cases.
class SearchCatalogController extends GetxController {
  final GetProductsUseCase _getProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  SearchCatalogController({
    required GetProductsUseCase getProductsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase;

  final TextEditingController searchTextController = TextEditingController();
  final RxList<Product> results = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedSort = 'default'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final List<String> trendingKeywords = const [
    'MacBook',
    'UltraPhone',
    'Audio',
    'Smart Watch',
    'Sneakers',
    'Camera',
    'Keyboard',
  ];

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      _fetchCategories(),
      searchProducts(),
    ]);
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _getCategoriesUseCase();
      categories.assignAll(cats);
    } catch (_) {}
  }

  Future<void> searchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetched = await _getProductsUseCase(
        limit: 50,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        category: selectedCategoryId.value.isNotEmpty
            ? selectedCategoryId.value
            : null,
      );
      results.assignAll(_applyClientSortAndFilter(fetched));
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load products';
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> _applyClientSortAndFilter(List<Product> input) {
    final list = input.toList();
    final q = searchQuery.value.trim().toLowerCase();
    final filtered = q.isEmpty
        ? list
        : list.where((p) {
            return p.name.toLowerCase().contains(q) ||
                (p.category?.toLowerCase().contains(q) ?? false) ||
                (p.description?.toLowerCase().contains(q) ?? false);
          }).toList();

    switch (selectedSort.value) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));
        break;
      case 'popular':
        filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'default':
      default:
        break;
    }
    return filtered;
  }

  void onQueryChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), searchProducts);
  }

  void applyTrendingKeyword(String keyword) {
    searchTextController.text = keyword;
    searchTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    searchQuery.value = keyword;
    searchProducts();
  }

  void selectCategory(String categoryId) {
    if (selectedCategoryId.value == categoryId) {
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = categoryId;
    }
    searchProducts();
  }

  void setSort(String sort) {
    selectedSort.value = sort;
    results.assignAll(_applyClientSortAndFilter(results));
  }

  void resetAll() {
    _debounce?.cancel();
    searchTextController.clear();
    searchQuery.value = '';
    selectedCategoryId.value = '';
    selectedSort.value = 'default';
    searchProducts();
  }
}
