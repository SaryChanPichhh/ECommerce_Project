import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Order>> getOrders({int? page, int? limit, String? status}) async {
    try {
      return await _remoteDataSource.getOrders(
        page: page,
        limit: limit,
        status: status,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Order> getOrder(String id) async {
    try {
      return await _remoteDataSource.getOrder(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Order not found');
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<List<Order>> createOrder({
    required String cartId,
    required String shippingAddressId,
    String? idempotencyKey,
    List<OrderItem>? fallbackItems,
    double? fallbackTotal,
    String? fallbackStoreName,
  }) async {
    try {
      final items = fallbackItems
          ?.map((i) => OrderItemModel(
                id: i.id,
                productId: i.productId,
                productVariantId: i.productVariantId,
                productName: i.productName,
                variantName: i.variantName,
                sku: i.sku,
                productImageUrl: i.productImageUrl,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                totalPrice: i.totalPrice,
              ))
          .toList();

      return await _remoteDataSource.createOrder(
        cartId: cartId,
        shippingAddressId: shippingAddressId,
        idempotencyKey: idempotencyKey,
        fallbackItems: items,
        fallbackTotal: fallbackTotal,
        fallbackStoreName: fallbackStoreName,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<OrderPaymentBatch> payOrders({
    required List<String> orderIds,
    String? idempotencyKey,
    String? simulateOutcome,
    String? failureReason,
  }) async {
    try {
      return await _remoteDataSource.payOrders(
        orderIds: orderIds,
        idempotencyKey: idempotencyKey,
        simulateOutcome: simulateOutcome,
        failureReason: failureReason,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<OrderPayment> getOrderPayment(String orderId) async {
    try {
      return await _remoteDataSource.getOrderPayment(orderId);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Order> cancelOrder(String id) async {
    try {
      return await _remoteDataSource.cancelOrder(id);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<List<OrderStatusHistory>> getOrderStatusHistory(String orderId) async {
    try {
      return await _remoteDataSource.getOrderStatusHistory(orderId);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<List<OrderShipment>> getOrderShipments(String orderId) async {
    try {
      return await _remoteDataSource.getOrderShipments(orderId);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<OrderShipment> getShipment(String shipmentId) async {
    try {
      return await _remoteDataSource.getShipment(shipmentId);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<List<ShipmentEvent>> getShipmentEvents(String shipmentId) async {
    try {
      return await _remoteDataSource.getShipmentEvents(shipmentId);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<OrderShipment> confirmDelivery(
    String shipmentId, {
    String? note,
  }) async {
    try {
      return await _remoteDataSource.confirmDelivery(shipmentId, note: note);
    } on NetworkException {
      throw const NetworkFailure();
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
