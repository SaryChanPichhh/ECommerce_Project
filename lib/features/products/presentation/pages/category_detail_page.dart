import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/product.dart';
import '../controllers/category_controller.dart';
import '../widgets/product_grid_card.dart';

class CategoryDetailPage extends GetView<CategoryController> {
  const CategoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(controller.categoryName),
        actions: [
          Obx(() {
            final count = cartController.cart.value?.items.length ?? 0;
            return IconButton(
              tooltip: 'cart'.tr,
              icon: Badge(
                backgroundColor: AppColors.error,
                textColor: Colors.white,
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              onPressed: () => Get.toNamed(AppRoutes.cart),
            );
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return AppLoading(message: 'loading_products'.tr);
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.products.isEmpty) {
          return AppError(
            message: controller.errorMessage.value,
            onRetry: controller.fetchProducts,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Category Banner Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(
                        color: theme.dividerColor
                            .withValues(alpha: isDark ? 0.25 : 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          child: AppNetworkImage(
                            imageUrl: controller.categoryImageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.category_rounded,
                            fallbackIconSize: 28,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.categoryName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusRound,
                                  ),
                                ),
                                child: Text(
                                  '${controller.products.length} ${'items_count'.tr}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (controller.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmpty(
                    message: 'no_products_in_category'.tr,
                    actionLabel: 'explore_catalog'.tr,
                    onAction: () => Get.toNamed(AppRoutes.products),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.xs,
                    AppDimensions.md,
                    AppDimensions.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDimensions.md,
                      crossAxisSpacing: AppDimensions.md,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = controller.products[index];
                        return ProductGridCard(
                          product: product,
                          onTap: () => Get.toNamed(
                            '/products/${product.id}',
                            arguments: product.id,
                          ),
                          onAddToCartTap: () => _handleAddToCart(product),
                        );
                      },
                      childCount: controller.products.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _handleAddToCart(Product product) async {
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();
    final inStockVariants = product.variants.where((v) => v.isInStock);
    final selectedVariant = inStockVariants.isNotEmpty
        ? inStockVariants.first
        : (product.variants.isNotEmpty ? product.variants.first : null);
    await cartController.addToCart(
      productId: product.id,
      variantId: selectedVariant?.id,
      quantity: 1,
      productName: product.name,
      unitPrice: selectedVariant?.price ?? product.price,
      productImageUrl: product.imageUrl,
      variantName: selectedVariant?.name,
    );
  }
}
