import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../controllers/category_controller.dart';
import '../widgets/product_card.dart';

class CategoryDetailPage extends GetView<CategoryController> {
  const CategoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.categoryName),
      ),
      body: Obx(() {
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
          return const AppEmpty(
            message: 'No products found in this category',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ProductCard(
                product: product,
                onTap: () => Get.toNamed(
                  '/products/${product.id}',
                  arguments: product.id,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
