import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order.dart';
import '../controllers/order_controller.dart';

class OrderListPage extends GetView<OrderController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_orders'.tr),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: secondaryColor,
            tabs: [
              Tab(text: 'order_tab'.tr),
              Tab(text: 'history_tab'.tr),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.orders.isEmpty) {
            return AppLoading(message: 'loading_orders'.tr);
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.orders.isEmpty) {
            return AppError(
              message: controller.errorMessage.value,
              onRetry: controller.fetchOrders,
            );
          }

          final activeOrders =
              controller.orders.where((o) => o.isActive).toList();
          final historyOrders =
              controller.orders.where((o) => o.isTerminal).toList();

          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            color: AppColors.primary,
            child: TabBarView(
              children: [
                _buildOrderList(context, activeOrders, isActive: true),
                _buildOrderList(context, historyOrders, isActive: false),
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

  Widget _buildOrderList(
    BuildContext context,
    List<Order> orders, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    if (orders.isEmpty) {
      return AppEmpty(
        message: 'no_orders_found'.tr,
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
            '${'order_tab'.tr} #${order.id}';
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
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
            ),
          ),
          elevation: isDark ? 1 : 2,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.shopping_bag_outlined,
                        fallbackIconSize: 28,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
                                  color: statusColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
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
                                          ? '${'variant'.tr}: ${item.variantName}'
                                          : '${'order_tab'.tr}: $subtitleOrderNo',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: secondaryColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${'items_label'.tr} / ${'qty'.tr}$itemQty',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: secondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(
                          '/orders/${order.id}',
                          arguments: order.id,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
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
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text(
                          order.canPay
                              ? 'pay_now'.tr
                              : (isActive ? 'tracking'.tr : 'order_summary'.tr),
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
