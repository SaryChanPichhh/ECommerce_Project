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
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_grid_card.dart';
import '../controllers/search_catalog_controller.dart';

class SearchPage extends GetView<SearchCatalogController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('search'.tr),
        actions: [
          _buildCartButton(theme),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar & Sort Trigger
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.xs,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.55),
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
                controller: controller.searchTextController,
                onChanged: controller.onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'search_products_hint'.tr,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  suffixIcon: Obx(() {
                    final hasQuery = controller.searchQuery.value.isNotEmpty;
                    final hasSort = controller.selectedSort.value != 'default';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasQuery)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => controller.onQueryChanged('') ,
                            onLongPress: controller.resetAll,
                          ),
                        IconButton(
                          tooltip: 'sort_options'.tr,
                          icon: Icon(
                            Icons.tune_rounded,
                            color: hasSort
                                ? AppColors.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            size: 20,
                          ),
                          onPressed: () => _showSortBottomSheet(context, theme),
                        ),
                      ],
                    );
                  }),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Trending Search Keywords
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.xs,
              AppDimensions.md,
              0,
            ),
            child: Text(
              'trending_searches'.tr,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              itemCount: controller.trendingKeywords.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
              itemBuilder: (context, index) {
                final keyword = controller.trendingKeywords[index];
                return Obx(() {
                  final active = controller.searchQuery.value.toLowerCase() ==
                      keyword.toLowerCase();
                  return ActionChip(
                    avatar: Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: active ? Colors.white : AppColors.warning,
                    ),
                    label: Text(
                      keyword,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: active
                        ? AppColors.primary
                        : theme.cardColor,
                    side: BorderSide(
                      color: active
                          ? AppColors.primary
                          : theme.dividerColor.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    onPressed: () {
                      if (active) {
                        controller.searchTextController.clear();
                        controller.onQueryChanged('');
                      } else {
                        controller.applyTrendingKeyword(keyword);
                      }
                    },
                  );
                });
              },
            ),
          ),

          const SizedBox(height: AppDimensions.sm),

          // Dynamic API Category Chips
          Obx(() {
            final cats = controller.categories;
            if (cats.isEmpty) return const SizedBox.shrink();
            final selectedCatId = controller.selectedCategoryId.value;

            return SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: cats.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final catId = isAll ? '' : cats[index - 1].id;
                  final label = isAll ? 'all'.tr : cats[index - 1].name;
                  final isSelected = selectedCatId == catId;

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) {
                      if (isAll) {
                        controller.selectedCategoryId.value = '';
                        controller.searchProducts();
                      } else {
                        controller.selectCategory(catId);
                      }
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: theme.cardColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : theme.dividerColor.withValues(alpha: 0.35),
                    ),
                  );
                },
              ),
            );
          }),

          // Results count + Active sort indicator
          Obx(() {
            final count = controller.results.length;
            final sort = controller.selectedSort.value;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$count ${'items_count'.tr}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sort != 'default')
                    GestureDetector(
                      onTap: () => controller.setSort('default'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusRound),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${'sorted_by'.tr}: ${_sortLabel(sort)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          // Results Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.results.isEmpty) {
                return AppLoading(message: 'loading_products'.tr);
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.results.isEmpty) {
                return AppError(
                  message: controller.errorMessage.value,
                  onRetry: controller.searchProducts,
                );
              }
              if (controller.results.isEmpty) {
                return AppEmpty(
                  icon: Icons.search_off_rounded,
                  message: 'no_products_match'.tr,
                  actionLabel: 'reset_filters'.tr,
                  onAction: controller.resetAll,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadInitialData,
                color: AppColors.primary,
                child: GridView.builder(
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
                  itemCount: controller.results.length,
                  itemBuilder: (context, index) {
                    final product = controller.results[index];
                    return ProductGridCard(
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
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(ThemeData theme) {
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();

    return Obx(() {
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
    });
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'price_asc':
        return 'sort_price_asc'.tr;
      case 'price_desc':
        return 'sort_price_desc'.tr;
      case 'rating':
        return 'sort_rating'.tr;
      case 'popular':
        return 'sort_popular'.tr;
      case 'default':
      default:
        return 'sort_default'.tr;
    }
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
                    width: 40,
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
                _buildSortTile(ctx, 'sort_default'.tr, 'default'),
                _buildSortTile(ctx, 'sort_price_asc'.tr, 'price_asc'),
                _buildSortTile(ctx, 'sort_price_desc'.tr, 'price_desc'),
                _buildSortTile(ctx, 'sort_rating'.tr, 'rating'),
                _buildSortTile(ctx, 'sort_popular'.tr, 'popular'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(BuildContext context, String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedSort.value == value;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
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
