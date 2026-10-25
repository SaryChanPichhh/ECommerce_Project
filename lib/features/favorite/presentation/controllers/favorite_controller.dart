import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';

class FavoriteController extends GetxController {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final AddFavoriteUseCase? _addFavoriteUseCase;
  final RemoveFavoriteUseCase? _removeFavoriteUseCase;

  FavoriteController({
    required GetFavoritesUseCase getFavoritesUseCase,
    AddFavoriteUseCase? addFavoriteUseCase,
    RemoveFavoriteUseCase? removeFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _addFavoriteUseCase = addFavoriteUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase;

  final RxList<Favorite> _allFavorites = <Favorite>[].obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;
  final RxSet<String> favoriteProductIds = <String>{}.obs;
  final RxSet<String> _explicitlyRemovedIds = <String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final List<String> filters = [
    'All',
    'Latest',
    'Most Popular',
    'Cheapest',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Fetch all favorites from the backend once, then apply local filters
      final result = await _getFavoritesUseCase();
      _allFavorites.assignAll(result);
      favoriteProductIds.addAll(result.map((item) => item.id));
      favoriteProductIds.removeAll(_explicitlyRemovedIds);
      _applyFilters();
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorite(String productId, {bool defaultIsFavorite = false}) {
    if (_explicitlyRemovedIds.contains(productId)) {
      return false;
    }
    if (favoriteProductIds.contains(productId)) {
      return true;
    }
    return defaultIsFavorite;
  }

  Future<bool> toggleFavoriteProduct(Product product) async {
    return await toggleFavorite(
      productId: product.id,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      defaultIsFavorite: product.isFavorite,
    );
  }

  Future<bool> toggleFavoriteStoreProduct(dynamic product) async {
    return await toggleFavorite(
      productId: product.id as String,
      name: product.name as String,
      price: (product.basePrice as num).toDouble(),
      imageUrl: product.primaryImageUrl as String?,
      defaultIsFavorite: (product.isFavorite as bool?) ?? false,
    );
  }

  Future<bool> toggleFavorite({
    required String productId,
    String? name,
    double? price,
    String? imageUrl,
    String? category,
    bool defaultIsFavorite = false,
  }) async {
    final currentlyFavorite =
        isFavorite(productId, defaultIsFavorite: defaultIsFavorite);
    final willBeFavorite = !currentlyFavorite;

    if (willBeFavorite) {
      favoriteProductIds.add(productId);
      _explicitlyRemovedIds.remove(productId);

      if (!_allFavorites.any((f) => f.id == productId)) {
        final newFav = Favorite(
          id: productId,
          name: name ?? '',
          price: price ?? 0.0,
          imageUrl: imageUrl,
          category: category,
          favoritedAt: DateTime.now(),
        );
        _allFavorites.insert(0, newFav);
        _applyFilters();
      }

      Helpers.showSuccess('added_to_favorites'.tr);

      try {
        if (_addFavoriteUseCase != null) {
          await _addFavoriteUseCase(productId);
        }
      } catch (_) {}
    } else {
      favoriteProductIds.remove(productId);
      _explicitlyRemovedIds.add(productId);
      _allFavorites.removeWhere((f) => f.id == productId);
      _applyFilters();

      Helpers.showSuccess('removed_from_favorites'.tr);

      try {
        if (_removeFavoriteUseCase != null) {
          await _removeFavoriteUseCase(productId);
        }
      } catch (_) {}
    }

    return willBeFavorite;
  }

  void _applyFilters() {
    List<Favorite> result = _allFavorites.toList();

    // 1. Apply Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 2. Apply Sorting/Filter Chips
    switch (selectedFilter.value) {
      case 'Latest':
        result.sort((a, b) {
          final dateA = a.favoritedAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.favoritedAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA); // Descending (newest first)
        });
        break;
      case 'Cheapest':
        result.sort((a, b) => a.price.compareTo(b.price)); // Ascending (lowest first)
        break;
      case 'Most Popular':
        // Assuming quantity represents popularity or sales, otherwise just reverse for mock
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'All':
      default:
        // Keep original fetched order
        break;
    }

    favorites.assignAll(result);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  Future<void> refreshFavorites() => fetchFavorites();
}
