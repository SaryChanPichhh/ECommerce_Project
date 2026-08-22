import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;
  CustomerRepositoryImpl({required CustomerRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Customer>> getCustomers({int? page, int? limit, String? search}) async {
    try { return await _remoteDataSource.getCustomers(page: page, limit: limit, search: search); }
    on NetworkException { throw const NetworkFailure(); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }

  @override
  Future<Customer> getCustomer(String id) async {
    try { return await _remoteDataSource.getCustomer(id); }
    on NotFoundException { throw const NotFoundFailure(message: 'Customer not found'); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    try { return await _remoteDataSource.createCustomer(CustomerModel.fromEntity(customer).toJson()); }
    on ValidationException catch (e) { throw ValidationFailure(message: e.message, errors: e.errors); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    try { return await _remoteDataSource.updateCustomer(customer.id, CustomerModel.fromEntity(customer).toJson()); }
    on NotFoundException { throw const NotFoundFailure(message: 'Customer not found'); }
    on ValidationException catch (e) { throw ValidationFailure(message: e.message, errors: e.errors); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try { await _remoteDataSource.deleteCustomer(id); }
    on NotFoundException { throw const NotFoundFailure(message: 'Customer not found'); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }
}
