import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repository;
  GetCustomersUseCase({required CustomerRepository repository}) : _repository = repository;
  Future<List<Customer>> call({int? page, int? limit, String? search}) => _repository.getCustomers(page: page, limit: limit, search: search);
}
