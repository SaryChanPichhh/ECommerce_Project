import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status});
  Future<OrderModel> getOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  OrderRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status}) async {
    final qp = <String, dynamic>{};
    if (page != null) qp['page'] = page;
    if (limit != null) qp['limit'] = limit;
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final response = await _apiClient.get('/orders', queryParameters: qp);
    final data = response.data;
    List<dynamic> items;
    if (data is Map<String, dynamic>) { items = data['data'] as List<dynamic>? ?? []; } else if (data is List) { items = data; } else { items = []; }
    return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final response = await _apiClient.get('/orders/$id');
    final data = response.data;
    final d = data is Map<String, dynamic> && data.containsKey('data') ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
    return OrderModel.fromJson(d);
  }
}
