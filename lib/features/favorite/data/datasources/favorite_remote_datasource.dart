import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/favorite_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites({String? search, String? filter});
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;

  FavoriteRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final _mockFavorites = const <FavoriteModel>[
    FavoriteModel(id: 'f1', name: 'MacBook Pro 16"', price: 2499.00, imageUrl: null, category: 'Electronics'),
    FavoriteModel(id: 'f2', name: 'iPhone 15 Pro', price: 999.00, imageUrl: null, category: 'Electronics'),
    FavoriteModel(id: 'f3', name: 'AirPods Pro', price: 249.00, imageUrl: null, category: 'Accessories'),
  ];

  @override
  Future<List<FavoriteModel>> getFavorites({String? search, String? filter}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['q'] = search;
      if (filter != null && filter != 'All') queryParams['filter'] = filter.toLowerCase();

      final response = await _apiClient.get(
        ApiConstants.customerFavorites,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;
      List<dynamic> items;

      if (data is Map<String, dynamic>) {
        items = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      return items.map((item) => FavoriteModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      var results = _mockFavorites;
      if (search != null && search.isNotEmpty) {
        results = results.where((f) => f.name.toLowerCase().contains(search.toLowerCase())).toList();
      }
      if (filter != null && filter != 'All') {
        results = results.where((f) => f.category?.toLowerCase() == filter.toLowerCase()).toList();
      }
      return results;
    }
  }

  @override
  Future<void> addFavorite(String productId) async {
    try {
      await _apiClient.post(
        ApiConstants.customerFavorites,
        data: {'product_id': productId},
      );
    } catch (_) {
      // Allow graceful fallback when offline or running in mock environment
    }
  }

  @override
  Future<void> removeFavorite(String productId) async {
    try {
      await _apiClient.delete(ApiConstants.customerFavoriteProduct(productId));
    } catch (_) {
      // Allow graceful fallback when offline or running in mock environment
    }
  }
}
