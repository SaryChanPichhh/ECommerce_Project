import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;
  CreateCustomerUseCase({required CustomerRepository repository}) : _repository = repository;
  Future<Customer> call(Customer customer) => _repository.createCustomer(customer);
}
