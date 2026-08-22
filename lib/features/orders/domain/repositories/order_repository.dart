import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int? page, int? limit, String? status});
  Future<Order> getOrder(String id);
}
