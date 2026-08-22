import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int? page, int? limit, String? search});
  Future<ProductModel> getProduct(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ProductModel>> getProducts({int? page, int? limit, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(
      '/products',
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
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    final response = await _apiClient.get('/products/$id');
    final data = response.data;
    final productData = data is Map<String, dynamic> && data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return ProductModel.fromJson(productData);
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/products', data: data);
    final responseData = response.data;
    final productData =
        responseData is Map<String, dynamic> && responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData as Map<String, dynamic>;
    return ProductModel.fromJson(productData);
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/products/$id', data: data);
    final responseData = response.data;
    final productData =
        responseData is Map<String, dynamic> && responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData as Map<String, dynamic>;
    return ProductModel.fromJson(productData);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('/products/$id');
  }
}
