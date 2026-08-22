import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Order>> getOrders({int? page, int? limit, String? status}) async {
    try { return await _remoteDataSource.getOrders(page: page, limit: limit, status: status); }
    on NetworkException { throw const NetworkFailure(); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }

  @override
  Future<Order> getOrder(String id) async {
    try { return await _remoteDataSource.getOrder(id); }
    on NotFoundException { throw const NotFoundFailure(message: 'Order not found'); }
    on AppException catch (e) { throw ServerFailure(message: e.message); }
    catch (e) { throw UnknownFailure(message: e.toString()); }
  }
}
