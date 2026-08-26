import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search.dart';

class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          ProductSearch(
            onChanged: controller.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoading(message: 'Loading products...');
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return AppError(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchProducts,
                );
              }

              if (controller.products.isEmpty) {
                return AppEmpty(
                  message: 'No products found',
                  actionLabel: 'Add Product',
                  onAction: () => Get.toNamed('/products/create'),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                child: ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(
                        '/products/:id',
                        parameters: {'id': product.id},
                      ),
                      onEdit: () async {
                        final result = await Get.toNamed(
                          '/products/edit',
                          arguments: product.id,
                        );
                        if (result == true) controller.fetchProducts();
                      },
                      onDelete: () => controller.deleteProduct(product.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/products/create');
          if (result == true) controller.fetchProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
