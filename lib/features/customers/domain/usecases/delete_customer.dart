import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository _repository;
  DeleteCustomerUseCase({required CustomerRepository repository}) : _repository = repository;
  Future<void> call(String id) => _repository.deleteCustomer(id);
}
