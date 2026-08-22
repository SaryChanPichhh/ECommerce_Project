import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({int? page, int? limit, String? search});
  Future<Customer> getCustomer(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
