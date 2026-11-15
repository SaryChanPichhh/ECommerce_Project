import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_card.dart';

class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: Column(
        children: [
          _buildSearchBar(context, theme),
          _buildCategoryChips(theme),
          _buildSortIndicator(context, theme),
          Expanded(
            child: _buildProductList(context, theme),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'products'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Obx(
            () => Text(
              '${controller.filteredProducts.length} ${'items_count'.tr}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => IconButton(
            tooltip:
                controller.isGridView.value ? 'list_view'.tr : 'grid_view'.tr,
            icon: Icon(
              controller.isGridView.value
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            onPressed: controller.toggleViewMode,
          ),
        ),
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
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'search_products_hint'.tr,
            hintStyle: TextStyle(
              fontSize: 13,
              color: secondaryColor,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon: Obx(() {
              final hasQuery = controller.searchQuery.value.isNotEmpty;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasQuery)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: controller.clearSearch,
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: controller.selectedSort.value != 'default'
                          ? AppColors.primary
                          : secondaryColor,
                      size: 20,
                    ),
                    tooltip: 'sort_options'.tr,
                    onPressed: () => _showSortBottomSheet(context, theme),
                  ),
                ],
              );
            }),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return Obx(() {
      final categories = controller.categories;
      if (categories.length <= 1) return const SizedBox.shrink();

      final current = controller.selectedCategory.value;

      return SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: 6,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = current == cat;
            final displayLabel = cat == 'All' ? 'all'.tr : cat;

            return ChoiceChip(
              label: Text(displayLabel),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(cat),
              selectedColor: AppColors.primary,
              backgroundColor: theme.cardColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : theme.dividerColor.withValues(alpha: 0.35),
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
              pressElevation: 0,
            );
          },
        ),
      );
    });
  }

  Widget _buildSortIndicator(BuildContext context, ThemeData theme) {
    return Obx(() {
      final sort = controller.selectedSort.value;
      if (sort == 'default') return const SizedBox.shrink();

      String sortLabel = '';
      switch (sort) {
        case 'price_asc':
          sortLabel = 'sort_price_asc'.tr;
          break;
        case 'price_desc':
          sortLabel = 'sort_price_desc'.tr;
          break;
        case 'rating':
          sortLabel = 'sort_rating'.tr;
          break;
        case 'popular':
          sortLabel = 'sort_popular'.tr;
          break;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 4,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${'sorted_by'.tr}: $sortLabel',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => controller.setSort('default'),
                    child: const Icon(
                      Icons.cancel,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductList(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return Center(child: AppLoading(message: 'loading_products'.tr));
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.products.isEmpty) {
        return Center(
          child: AppError(
            message: controller.errorMessage.value,
            onRetry: controller.fetchProducts,
          ),
        );
      }

      final items = controller.filteredProducts;

      if (items.isEmpty) {
        final hasActiveFilter = controller.searchQuery.value.isNotEmpty ||
            controller.selectedCategory.value != 'All';

        return Center(
          child: AppEmpty(
            message: hasActiveFilter
                ? 'no_products_match'.tr
                : 'no_products_found'.tr,
            actionLabel: hasActiveFilter ? 'reset_filters'.tr : null,
            onAction: hasActiveFilter
                ? () {
                    controller.clearSearch();
                    controller.setCategory('All');
                    controller.setSort('default');
                  }
                : null,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshProducts,
        color: AppColors.primary,
        child: controller.isGridView.value
            ? GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.xs,
                  AppDimensions.md,
                  AppDimensions.xl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.md,
                  crossAxisSpacing: AppDimensions.md,
                  childAspectRatio: 0.62,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return ProductGridCard(
                    product: product,
                    onTap: () => Get.toNamed(
                      '/products/${product.id}',
                      arguments: product.id,
                    ),
                    onAddToCartTap: () => _handleAddToCart(product),
                  );
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.xs,
                  AppDimensions.md,
                  AppDimensions.xl,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Get.toNamed(
                      '/products/${product.id}',
                      arguments: product.id,
                    ),
                    onAddToCartTap: () => _handleAddToCart(product),
                  );
                },
              ),
      );
    });
  }

  void _showSortBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'sort_products'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                _buildSortRadio(ctx, 'sort_default'.tr, 'default'),
                _buildSortRadio(ctx, 'sort_price_asc'.tr, 'price_asc'),
                _buildSortRadio(ctx, 'sort_price_desc'.tr, 'price_desc'),
                _buildSortRadio(ctx, 'sort_rating'.tr, 'rating'),
                _buildSortRadio(ctx, 'sort_popular'.tr, 'popular'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortRadio(BuildContext context, String title, String value) {
    return Obx(() {
      final isSelected = controller.selectedSort.value == value;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () {
          controller.setSort(value);
          Navigator.pop(context);
        },
      );
    });
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
