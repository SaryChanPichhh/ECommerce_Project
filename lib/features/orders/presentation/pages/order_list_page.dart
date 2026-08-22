import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/order_controller.dart';

class OrderListPage extends GetView<OrderController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Obx(() => Row(
              children: ['All', 'pending', 'processing', 'completed', 'cancelled'].map((status) {
                final isSelected = (status == 'All' && controller.selectedStatus.value.isEmpty) || controller.selectedStatus.value == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sm),
                  child: FilterChip(label: Text(status[0].toUpperCase() + status.substring(1)), selected: isSelected, onSelected: (_) => controller.onStatusFilterChanged(status == 'All' ? '' : status)),
                );
              }).toList(),
            )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const AppLoading(message: 'Loading orders...');
              if (controller.errorMessage.value.isNotEmpty) return AppError(message: controller.errorMessage.value, onRetry: controller.fetchOrders);
              if (controller.orders.isEmpty) return const AppEmpty(message: 'No orders found', icon: Icons.shopping_cart_outlined);
              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                child: ListView.builder(
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: _statusColor(order.status).withValues(alpha: 0.1), child: Icon(Icons.receipt_outlined, color: _statusColor(order.status))),
                        title: Text('Order #${order.id}'),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (order.customerName != null) Text(order.customerName!),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _statusColor(order.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(order.status)))),
                        ]),
                        trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => Get.toNamed('/orders/${order.id}', arguments: order.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppColors.warning;
      case 'processing': return AppColors.info;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondaryLight;
    }
  }
}
