import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_order.dart';
import '../bindings/order_binding.dart';
import '../controllers/order_controller.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? order;
  List<OrderShipment> shipments = const [];
  List<OrderStatusHistory> statusHistory = const [];
  bool isLoading = true;
  bool isSubmittingAction = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<OrderRepository>() ||
        !Get.isRegistered<GetOrderUseCase>()) {
      OrderBinding().dependencies();
    }
    _loadOrder();
  }

  String? _resolveOrderId() {
    final arg = Get.arguments;
    if (arg is String && arg.isNotEmpty) return arg;
    final paramId = Get.parameters['id'];
    if (paramId != null && paramId.isNotEmpty) return paramId;
    return null;
  }

  Future<void> _loadOrder() async {
    final id = _resolveOrderId();
    if (id == null) {
      setState(() {
        errorMessage = 'Order ID not provided';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final repo = Get.find<OrderRepository>();
      final result = await Get.find<GetOrderUseCase>()(id);

      List<OrderShipment> loadedShipments = result.shipments ?? const [];
      if (loadedShipments.isEmpty && !id.startsWith('ORD-')) {
        loadedShipments = await repo.getOrderShipments(id);
      }

      // Enrich shipments with events if events were not embedded
      final enrichedShipments = <OrderShipment>[];
      for (final s in loadedShipments) {
        if (s.events.isEmpty && s.id.isNotEmpty) {
          final events = await repo.getShipmentEvents(s.id);
          enrichedShipments.add(
            OrderShipment(
              id: s.id,
              orderId: s.orderId,
              carrierName: s.carrierName,
              trackingNumber: s.trackingNumber,
              status: s.status,
              shippedAt: s.shippedAt,
              deliveredAt: s.deliveredAt,
              events: events,
            ),
          );
        } else {
          enrichedShipments.add(s);
        }
      }

      List<OrderStatusHistory> loadedHistory =
          result.statusHistory ?? const [];
      if (loadedHistory.isEmpty && !id.startsWith('ORD-')) {
        loadedHistory = await repo.getOrderStatusHistory(id);
      }

      if (!mounted) return;
      setState(() {
        order = result;
        shipments = enrichedShipments;
        statusHistory = loadedHistory;
        isLoading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load order';
        isLoading = false;
      });
    }
  }

  Future<void> _handlePayOrder() async {
    if (order == null || isSubmittingAction) return;
    setState(() => isSubmittingAction = true);
    try {
      final controller = Get.find<OrderController>();
      final ok = await controller.completeOrderPayment(order!.id);
      if (ok) {
        await _loadOrder();
      }
    } finally {
      if (mounted) setState(() => isSubmittingAction = false);
    }
  }

  Future<void> _handleCancelOrder() async {
    if (order == null || isSubmittingAction) return;
    final confirmed = await Helpers.showConfirmDialog(
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order?',
      confirmText: 'Yes, Cancel',
      cancelText: 'No',
    );
    if (!confirmed) return;

    setState(() => isSubmittingAction = true);
    try {
      final controller = Get.find<OrderController>();
      final ok = await controller.cancelOrder(order!.id);
      if (ok) {
        await _loadOrder();
      }
    } finally {
      if (mounted) setState(() => isSubmittingAction = false);
    }
  }

  Future<void> _handleConfirmDelivery(OrderShipment shipment) async {
    if (isSubmittingAction) return;
    setState(() => isSubmittingAction = true);
    try {
      final controller = Get.find<OrderController>();
      final ok = await controller.confirmShipmentDelivery(
        shipment.id,
        note: 'Product received in good condition',
      );
      if (ok) {
        await _loadOrder();
      }
    } finally {
      if (mounted) setState(() => isSubmittingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = order != null
        ? (order!.orderNumber ?? 'Order #${order!.id}')
        : 'Order Detail';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isLoading
          ? const AppLoading()
          : errorMessage.isNotEmpty
              ? AppError(message: errorMessage, onRetry: _loadOrder)
              : order == null
                  ? const AppError(message: 'Order not found')
                  : RefreshIndicator(
                      onRefresh: _loadOrder,
                      child: ListView(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        children: [
                          _buildOrderSummaryCard(context, order!),
                          const SizedBox(height: AppDimensions.md),
                          if (order!.canPay || order!.canCustomerCancel)
                            _buildOrderActionsCard(order!),
                          if (order!.items != null &&
                              order!.items!.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              'Items (${order!.items!.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            ...order!.items!.map(
                              (item) => Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppDimensions.sm,
                                ),
                                child: ListTile(
                                  title: Text(
                                    item.productName ??
                                        'Product ${item.productId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (item.variantName != null &&
                                          item.variantName!.isNotEmpty)
                                        'Variant: ${item.variantName}',
                                      '${'qty'.tr}${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                    ].join(' • '),
                                  ),
                                  trailing: Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (shipments.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              'Shipments & Tracking',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            ...shipments.map(_buildShipmentCard),
                          ],
                          if (statusHistory.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              'Order Status Timeline',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            _buildStatusHistoryCard(statusHistory),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, Order ord) {
    final sColor = _statusColor(ord.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ord.orderNumber ?? 'Order #${ord.id}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    ord.status.toUpperCase(),
                    style: TextStyle(
                      color: sColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: sColor.withValues(alpha: 0.12),
                ),
              ],
            ),
            if (ord.storeName != null || ord.customerName != null) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Store: ${ord.storeName ?? ord.customerName}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (ord.payment != null) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Payment: ${ord.payment!.status.toUpperCase()}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const Divider(height: AppDimensions.lg),
            _buildPriceRow('Subtotal', ord.subtotalAmount),
            const SizedBox(height: 4),
            _buildPriceRow('Shipping', ord.shippingAmount),
            if (ord.discountAmount > 0) ...[
              const SizedBox(height: 4),
              _buildPriceRow('Discount', -ord.discountAmount),
            ],
            if (ord.taxAmount > 0) ...[
              const SizedBox(height: 4),
              _buildPriceRow('Tax', ord.taxAmount),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '\$${ord.totalAmount.toStringAsFixed(2)} ${ord.currency}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text('\$${amount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildOrderActionsCard(Order ord) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            if (ord.canPay)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSubmittingAction ? null : _handlePayOrder,
                  icon: const Icon(Icons.payment),
                  label: const Text('Complete Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (ord.canPay && ord.canCustomerCancel)
              const SizedBox(width: AppDimensions.sm),
            if (ord.canCustomerCancel)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmittingAction ? null : _handleCancelOrder,
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(OrderShipment shipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shipment.carrierName ?? 'Shipment',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shipment.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            if (shipment.trackingNumber != null &&
                shipment.trackingNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Tracking #: ${shipment.trackingNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
            if (shipment.canConfirmDelivery) ...[
              const SizedBox(height: AppDimensions.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmittingAction
                      ? null
                      : () => _handleConfirmDelivery(shipment),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm Receipt / Product Received'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (shipment.events.isNotEmpty) ...[
              const Divider(height: AppDimensions.lg),
              ...shipment.events.map(
                (ev) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ev.description ?? ev.status.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (ev.location != null &&
                                ev.location!.isNotEmpty)
                              Text(
                                ev.location!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistoryCard(List<OrderStatusHistory> history) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: history
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.fromStatus != null
                                  ? '${h.fromStatus!.toUpperCase()} → ${h.toStatus.toUpperCase()}'
                                  : h.toStatus.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (h.note != null && h.note!.isNotEmpty)
                              Text(
                                h.note!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
