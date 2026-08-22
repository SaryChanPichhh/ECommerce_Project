import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/customer_controller.dart';

class CustomerListPage extends GetView<CustomerController> {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(hintText: 'Search customers...', prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd))),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const AppLoading(message: 'Loading customers...');
              if (controller.errorMessage.value.isNotEmpty) return AppError(message: controller.errorMessage.value, onRetry: controller.fetchCustomers);
              if (controller.customers.isEmpty) return AppEmpty(message: 'No customers found', icon: Icons.people_outline, actionLabel: 'Add Customer', onAction: () => Get.toNamed('/customers/create'));
              return RefreshIndicator(
                onRefresh: controller.refreshCustomers,
                child: ListView.builder(
                  itemCount: controller.customers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                          child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.email ?? customer.phone ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) { if (v == 'edit') Get.toNamed('/customers/edit', arguments: customer.id); if (v == 'delete') controller.deleteCustomer(customer.id); },
                          itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                        ),
                        onTap: () => Get.toNamed('/customers/${customer.id}', arguments: customer.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { final result = await Get.toNamed('/customers/create'); if (result == true) controller.fetchCustomers(); },
        child: const Icon(Icons.add),
      ),
    );
  }
}
