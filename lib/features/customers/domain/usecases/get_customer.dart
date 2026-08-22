import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerUseCase {
  final CustomerRepository _repository;
  GetCustomerUseCase({required CustomerRepository repository}) : _repository = repository;
  Future<Customer> call(String id) => _repository.getCustomer(id);
}
