import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({int? page, int? limit, String? search});
  Future<CustomerModel> getCustomer(String id);
  Future<CustomerModel> createCustomer(Map<String, dynamic> data);
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data);
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient _apiClient;
  CustomerRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CustomerModel>> getCustomers({int? page, int? limit, String? search}) async {
    final qp = <String, dynamic>{};
    if (page != null) qp['page'] = page;
    if (limit != null) qp['limit'] = limit;
    if (search != null && search.isNotEmpty) qp['search'] = search;
    final response = await _apiClient.get('/customers', queryParameters: qp);
    final data = response.data;
    List<dynamic> items;
    if (data is Map<String, dynamic>) { items = data['data'] as List<dynamic>? ?? []; } else if (data is List) { items = data; } else { items = []; }
    return items.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CustomerModel> getCustomer(String id) async {
    final response = await _apiClient.get('/customers/$id');
    final data = response.data;
    final d = data is Map<String, dynamic> && data.containsKey('data') ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
    return CustomerModel.fromJson(d);
  }

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/customers', data: data);
    final rd = response.data;
    final d = rd is Map<String, dynamic> && rd.containsKey('data') ? rd['data'] as Map<String, dynamic> : rd as Map<String, dynamic>;
    return CustomerModel.fromJson(d);
  }

  @override
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/customers/$id', data: data);
    final rd = response.data;
    final d = rd is Map<String, dynamic> && rd.containsKey('data') ? rd['data'] as Map<String, dynamic> : rd as Map<String, dynamic>;
    return CustomerModel.fromJson(d);
  }

  @override
  Future<void> deleteCustomer(String id) async => await _apiClient.delete('/customers/$id');
}
