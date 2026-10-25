import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int? page, int? limit, String? status});
  Future<Order> getOrder(String id);
  Future<List<Order>> createOrder({
    required String cartId,
    required String shippingAddressId,
    String? idempotencyKey,
    List<OrderItem>? fallbackItems,
    double? fallbackTotal,
    String? fallbackStoreName,
  });
  Future<OrderPaymentBatch> payOrders({
    required List<String> orderIds,
    String? idempotencyKey,
    String? simulateOutcome,
    String? failureReason,
  });
  Future<OrderPayment> getOrderPayment(String orderId);
  Future<Order> cancelOrder(String id);
  Future<List<OrderStatusHistory>> getOrderStatusHistory(String orderId);
  Future<List<OrderShipment>> getOrderShipments(String orderId);
  Future<OrderShipment> getShipment(String shipmentId);
  Future<List<ShipmentEvent>> getShipmentEvents(String shipmentId);
  Future<OrderShipment> confirmDelivery(String shipmentId, {String? note});
}
