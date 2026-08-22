import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderUseCase {
  final OrderRepository _repository;
  GetOrderUseCase({required OrderRepository repository}) : _repository = repository;
  Future<Order> call(String id) => _repository.getOrder(id);
}
