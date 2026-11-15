import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
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
        errorMessage = 'order_not_found'.tr;
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
        errorMessage = 'order_not_found'.tr;
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
      title: 'cancel_order'.tr,
      message: 'Are you sure you want to cancel this order?',
      confirmText: 'Yes, Cancel',
      cancelText: 'cancel'.tr,
      isDestructive: true,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = order != null
        ? (order!.orderNumber ?? '${'order_tab'.tr} #${order!.id}')
        : 'detail'.tr;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isLoading
          ? AppLoading(message: 'loading_orders'.tr)
          : errorMessage.isNotEmpty
              ? AppError(message: errorMessage, onRetry: _loadOrder)
              : order == null
                  ? AppError(message: 'order_not_found'.tr)
                  : RefreshIndicator(
                      onRefresh: _loadOrder,
                      color: AppColors.primary,
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
                              '${'items_label'.tr} (${order!.items!.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            ...order!.items!.map(
                              (item) => Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppDimensions.sm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                  side: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: isDark ? 0.25 : 0.45,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd,
                                    ),
                                    child: AppNetworkImage(
                                      imageUrl: item.productImageUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      fallbackIcon: Icons.shopping_bag_outlined,
                                      fallbackIconSize: 22,
                                    ),
                                  ),
                                  title: Text(
                                    item.productName ??
                                        'Product ${item.productId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (item.variantName != null &&
                                          item.variantName!.isNotEmpty)
                                        '${'variant'.tr}: ${item.variantName}',
                                      '${'qty'.tr}${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                    ].join(' • '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (shipments.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              'shipments_and_tracking'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            ...shipments.map(_buildShipmentCard),
                          ],
                          if (statusHistory.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              'order_status_timeline'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);
    final sColor = _statusColor(ord.status);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
        ),
      ),
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
                    ord.orderNumber ?? '${'order_tab'.tr} #${ord.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    ord.status.toUpperCase(),
                    style: TextStyle(
                      color: sColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: sColor.withValues(alpha: 0.14),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (ord.storeName != null || ord.customerName != null) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                '${'store'.tr}: ${ord.storeName ?? ord.customerName}',
                style: TextStyle(color: secondaryColor),
              ),
            ],
            if (ord.payment != null) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                '${'payment'.tr}: ${ord.payment!.status.toUpperCase()}',
                style: TextStyle(color: secondaryColor),
              ),
            ],
            const Divider(height: AppDimensions.lg),
            _buildPriceRow(context, 'subtotal'.tr, ord.subtotalAmount),
            const SizedBox(height: 4),
            _buildPriceRow(context, 'shipping'.tr, ord.shippingAmount),
            if (ord.discountAmount > 0) ...[
              const SizedBox(height: 4),
              _buildPriceRow(context, 'discount'.tr, -ord.discountAmount),
            ],
            if (ord.taxAmount > 0) ...[
              const SizedBox(height: 4),
              _buildPriceRow(context, 'tax'.tr, ord.taxAmount),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${ord.totalAmount.toStringAsFixed(2)} ${ord.currency}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
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

  Widget _buildPriceRow(BuildContext context, String label, double amount) {
    final secondaryColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: secondaryColor)),
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
                  label: Text('complete_payment'.tr),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
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
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: Text(
                    'cancel_order'.tr,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(OrderShipment shipment) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

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
                    color: AppColors.info.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
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
                '${'tracking_number'.tr}: ${shipment.trackingNumber}',
                style: TextStyle(color: secondaryColor, fontSize: 13),
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
                  label: Text('confirm_delivery'.tr),
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
                                style: TextStyle(
                                  color: secondaryColor,
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
    final secondaryColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);

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
                                  ? '${h.fromStatus!.toUpperCase()} -> ${h.toStatus.toUpperCase()}'
                                  : h.toStatus.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (h.note != null && h.note!.isNotEmpty)
                              Text(
                                h.note!,
                                style: TextStyle(
                                  color: secondaryColor,
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
