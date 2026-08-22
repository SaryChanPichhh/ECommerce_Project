import '../../../../core/network/api_client.dart';
import '../models/favorite_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites({String? search, String? filter});
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;

  FavoriteRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<FavoriteModel>> getFavorites({String? search, String? filter}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter != 'All') queryParams['filter'] = filter.toLowerCase();

    final response = await _apiClient.get(
      '/favorites',
      queryParameters: queryParams,
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

    return items
        .map((item) => FavoriteModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
