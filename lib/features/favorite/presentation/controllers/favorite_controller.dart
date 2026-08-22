import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/usecases/get_favorites.dart';

class FavoriteController extends GetxController {
  final GetFavoritesUseCase _getFavoritesUseCase;

  FavoriteController({required GetFavoritesUseCase getFavoritesUseCase})
    : _getFavoritesUseCase = getFavoritesUseCase;

  final RxList<Favorite> _allFavorites = <Favorite>[].obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;
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
      _applyFilters();
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
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
          final dateA = a.favoritedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.favoritedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
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
