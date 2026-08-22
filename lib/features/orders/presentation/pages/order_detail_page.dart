import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_order.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? order;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() { super.initState(); _loadOrder(); }

  Future<void> _loadOrder() async {
    final id = Get.arguments as String?;
    if (id == null) { setState(() { errorMessage = 'Order ID not provided'; isLoading = false; }); return; }
    try {
      final result = await Get.find<GetOrderUseCase>()(id);
      setState(() { order = result; isLoading = false; });
    } on Failure catch (e) { setState(() { errorMessage = e.message; isLoading = false; }); }
    catch (e) { setState(() { errorMessage = 'Failed to load order'; isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(order != null ? 'Order #${order!.id}' : 'Order Detail')),
      body: isLoading ? const AppLoading()
          : errorMessage.isNotEmpty ? AppError(message: errorMessage, onRetry: _loadOrder)
          : order == null ? const AppError(message: 'Order not found')
          : ListView(padding: const EdgeInsets.all(AppDimensions.md), children: [
              Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.md), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order #${order!.id}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDimensions.sm),
                if (order!.customerName != null) Text('Customer: ${order!.customerName}'),
                const SizedBox(height: AppDimensions.sm),
                Chip(label: Text(order!.status.toUpperCase()), backgroundColor: _statusColor(order!.status).withValues(alpha: 0.1)),
                const SizedBox(height: AppDimensions.md),
                Text('Total: \$${order!.totalAmount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]))),
              if (order!.items != null && order!.items!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.md),
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                ...order!.items!.map((item) => Card(child: ListTile(
                  title: Text(item.productName ?? 'Product ${item.productId}'),
                  subtitle: Text('Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}'),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                ))),
              ],
              if (order!.notes != null) ...[
                const SizedBox(height: AppDimensions.md),
                Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.sm),
                Text(order!.notes!),
              ],
            ]),
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
