import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/order_controller.dart';
import '../../domain/entities/order.dart';

class OrderListPage extends GetView<OrderController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_orders'.tr),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Order'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const AppLoading(message: 'Loading orders...');
          if (controller.errorMessage.value.isNotEmpty) {
            return AppError(message: controller.errorMessage.value, onRetry: controller.fetchOrders);
          }

          final activeOrders =
              controller.orders.where((o) => o.isActive).toList();
          final historyOrders =
              controller.orders.where((o) => o.isTerminal).toList();

          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            child: TabBarView(
              children: [
                _buildOrderList(activeOrders, isActive: true),
                _buildOrderList(historyOrders, isActive: false),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
      default:
        return status.toUpperCase();
    }
  }

  Widget _buildOrderList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return const AppEmpty(
        message: 'No orders found',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final item = (order.items != null && order.items!.isNotEmpty)
            ? order.items!.first
            : null;
        final titleText = item?.productName ??
            order.storeName ??
            order.customerName ??
            order.orderNumber ??
            'Order #${order.id}';
        final subtitleOrderNo = order.orderNumber ?? order.id;
        final itemQty =
            item?.quantity ?? order.itemCount ?? order.items?.length ?? 1;
        final price = order.totalAmount;
        final statusColor = _statusColor(order.status);
        final statusLabel = _statusLabel(order.status);
        final imageUrl = item?.productImageUrl;

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          elevation: 2,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product / Order Thumbnail
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (imageUrl != null && imageUrl.isNotEmpty)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Order number / Variant, Qty, Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item?.variantName != null &&
                                              item!.variantName!.isNotEmpty
                                          ? 'Variant: ${item.variantName}'
                                          : 'Order: $subtitleOrderNo',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Items / Qty : $itemQty',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                const Divider(height: 1),
                const SizedBox(height: AppDimensions.md),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(
                          '/orders/${order.id}',
                          arguments: order.id,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text('detail'.tr),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (order.canPay) {
                            await controller.completeOrderPayment(order.id);
                          } else {
                            Get.toNamed(
                              '/orders/${order.id}',
                              arguments: order.id,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text(
                          order.canPay
                              ? 'Pay Now'
                              : (isActive ? 'Tracking' : 'Order Summary'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
