import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository _repository;
  UpdateCustomerUseCase({required CustomerRepository repository}) : _repository = repository;
  Future<Customer> call(Customer customer) => _repository.updateCustomer(customer);
}
