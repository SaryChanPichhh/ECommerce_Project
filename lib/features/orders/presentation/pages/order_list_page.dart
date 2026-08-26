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
          title: const Text('My Orders'),
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

          final activeOrders = controller.orders.where((o) => o.status.toLowerCase() != 'completed' && o.status.toLowerCase() != 'cancelled').toList();
          final historyOrders = controller.orders.where((o) => o.status.toLowerCase() == 'completed' || o.status.toLowerCase() == 'cancelled').toList();

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

  Widget _buildOrderList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return const AppEmpty(message: 'No orders found', icon: Icons.receipt_long_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Safely get the first item or use placeholders
        final item = (order.items != null && order.items!.isNotEmpty) ? order.items!.first : null;
        final itemName = item?.productName ?? 'Product Item';
        final itemQty = item?.quantity ?? 1;
        final price = order.totalAmount;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          elevation: 2,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image CenterLeft
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        image: const DecorationImage(
                          image: NetworkImage('https://via.placeholder.com/150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Name and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  itemName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? 'Progressing' : 'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Color, Qty, Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Color : Red', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Qty : $itemQty', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
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
                        onPressed: () => Get.toNamed('/orders/${order.id}', arguments: order.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
                        ),
                        child: const Text('Detail'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
                        ),
                        child: Text(isActive ? 'Tracking' : 'Received Order'),
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
