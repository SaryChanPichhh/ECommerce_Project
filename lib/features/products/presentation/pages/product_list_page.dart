import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          // Search Bar & Filter action
          _buildSearchBar(context, theme),

          // Horizontal Category Filter Chips
          _buildCategoryChips(theme),

          // Active Sort & Filter Indicator
          _buildSortIndicator(context, theme),

          // Main Product Catalog (Grid / List)
          Expanded(
            child: _buildProductList(context, theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/products/create');
          if (result == true) controller.fetchProducts();
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
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
              '${controller.filteredProducts.length} items',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Grid / List Toggle
        Obx(
          () => IconButton(
            tooltip:
                controller.isGridView.value ? 'List View' : 'Grid View',
            icon: Icon(
              controller.isGridView.value
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: controller.toggleViewMode,
          ),
        ),

        // Cart Icon with Badge
        IconButton(
          tooltip: 'Cart',
          icon: Badge(
            backgroundColor: AppColors.error,
            isLabelVisible: Get.isRegistered<CartController>() &&
                (Get.find<CartController>().cart.value?.items.isNotEmpty ?? false),
            label: Obx(() {
              if (!Get.isRegistered<CartController>()) return const Text('0');
              final count =
                  Get.find<CartController>().cart.value?.items.length ?? 0;
              return Text('$count');
            }),
            child: const Icon(Icons.shopping_bag_outlined, size: 22),
          ),
          onPressed: () => Get.toNamed('/cart'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
            hintText: 'Search products by name or category...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
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
                          : AppColors.textSecondaryLight,
                      size: 20,
                    ),
                    tooltip: 'Sort Options',
                    onPressed: () => _showSortBottomSheet(context, theme),
                  ),
                ],
              );
            }),
            border: InputBorder.none,
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

            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(cat),
              selectedColor: AppColors.primary,
              backgroundColor: theme.cardColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : theme.dividerColor.withValues(alpha: 0.1),
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
          sortLabel = 'Price: Low to High';
          break;
        case 'price_desc':
          sortLabel = 'Price: High to Low';
          break;
        case 'rating':
          sortLabel = 'Top Rated';
          break;
        case 'popular':
          sortLabel = 'Best Selling';
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
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sorted by: $sortLabel',
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
        return const Center(child: AppLoading(message: 'Loading products...'));
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
        return Center(
          child: AppEmpty(
            message: controller.searchQuery.value.isNotEmpty ||
                    controller.selectedCategory.value != 'All'
                ? 'No products match your filters'
                : 'No products found',
            actionLabel: controller.searchQuery.value.isNotEmpty ||
                    controller.selectedCategory.value != 'All'
                ? 'Reset Filters'
                : 'Add Product',
            onAction: () {
              if (controller.searchQuery.value.isNotEmpty ||
                  controller.selectedCategory.value != 'All') {
                controller.clearSearch();
                controller.setCategory('All');
                controller.setSort('default');
              } else {
                Get.toNamed('/products/create');
              }
            },
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
                  80,
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
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.xs,
                  AppDimensions.md,
                  80,
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
    });
  }

  void _showSortBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'Sort Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                _buildSortRadio(context, 'Featured / Default', 'default'),
                _buildSortRadio(context, 'Price: Low to High', 'price_asc'),
                _buildSortRadio(context, 'Price: High to Low', 'price_desc'),
                _buildSortRadio(context, 'Top Rated', 'rating'),
                _buildSortRadio(context, 'Best Selling', 'popular'),
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
