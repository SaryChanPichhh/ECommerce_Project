import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_orders.dart';

class OrderController extends GetxController {
  final GetOrdersUseCase _getOrdersUseCase;
  final OrderRepository? _orderRepository;

  OrderController({
    required GetOrdersUseCase getOrdersUseCase,
    OrderRepository? orderRepository,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _orderRepository = orderRepository;

  OrderRepository get _repo =>
      _orderRepository ?? Get.find<OrderRepository>();

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingAction = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fetchedOrders = await _getOrdersUseCase(
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
      );
      if (fetchedOrders.isNotEmpty) {
        orders.assignAll(fetchedOrders);
      } else {
        orders.assignAll([]);
      }
    } on Failure catch (e) {
      errorMessage.value = e.message;
      orders.assignAll([]);
    } catch (e) {
      errorMessage.value = 'Failed to load orders';
      orders.assignAll([]);
    } finally {
      isLoading.value = false;
    }
  }

  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
    fetchOrders();
  }

  Future<void> refreshOrders() => fetchOrders();

  /// Step 8 & 9: Complete payment for a pending order (`POST /api/v1/customer/orders/payment/`).
  Future<bool> completeOrderPayment(String orderId) async {
    isProcessingAction.value = true;
    try {
      await _repo.payOrders(
        orderIds: [orderId],
        idempotencyKey:
            'pay-${DateTime.now().microsecondsSinceEpoch}-$orderId',
      );
      await fetchOrders();
      Helpers.showSuccess('Payment completed! Order is now confirmed.');
      return true;
    } on Failure catch (e) {
      Helpers.showError(e.message);
      return false;
    } catch (_) {
      Helpers.showError('Failed to process payment');
      return false;
    } finally {
      isProcessingAction.value = false;
    }
  }

  /// Customer cancellation flow (`POST /api/v1/customer/orders/{order_id}/cancel/`).
  /// Allowed only while order is `pending` or `confirmed`.
  Future<bool> cancelOrder(String orderId) async {
    isProcessingAction.value = true;
    try {
      await _repo.cancelOrder(orderId);
      await fetchOrders();
      Helpers.showSuccess('Order cancelled successfully');
      return true;
    } on Failure catch (e) {
      Helpers.showError(e.message);
      return false;
    } catch (_) {
      Helpers.showError('Failed to cancel order');
      return false;
    } finally {
      isProcessingAction.value = false;
    }
  }

  /// Step 16 & 17: Customer confirms delivery (`POST /api/v1/customer/shipments/{shipment_id}/confirm-delivery`).
  /// Allowed when shipment is `out_for_delivery`. Transitions shipment & order to `delivered`.
  Future<bool> confirmShipmentDelivery(
    String shipmentId, {
    String? note,
  }) async {
    isProcessingAction.value = true;
    try {
      await _repo.confirmDelivery(
        shipmentId,
        note: note ?? 'Product received in good condition',
      );
      await fetchOrders();
      Helpers.showSuccess('Delivery confirmed! Order marked as delivered.');
      return true;
    } on Failure catch (e) {
      Helpers.showError(e.message);
      return false;
    } catch (_) {
      Helpers.showError('Failed to confirm delivery');
      return false;
    } finally {
      isProcessingAction.value = false;
    }
  }
}
