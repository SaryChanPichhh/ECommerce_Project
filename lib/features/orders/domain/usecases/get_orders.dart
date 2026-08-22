import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;
  GetOrdersUseCase({required OrderRepository repository}) : _repository = repository;
  Future<List<Order>> call({int? page, int? limit, String? status}) => _repository.getOrders(page: page, limit: limit, status: status);
}
