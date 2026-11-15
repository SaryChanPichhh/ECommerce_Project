import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/favorite.dart';
import '../controllers/favorite_controller.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  String _filterLabel(String rawFilter) {
    switch (rawFilter) {
      case 'All':
        return 'all'.tr;
      case 'Latest':
        return 'latest'.tr;
      case 'Most Popular':
        return 'most_popular'.tr;
      case 'Cheapest':
        return 'cheapest'.tr;
      default:
        return rawFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'favorite'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'notification'.tr,
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Get.toNamed(AppRoutes.profileNotification),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildFilterChips(theme),
          Expanded(child: _buildProductGrid(context, theme)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: AppTextField(
        hint: 'search_favorites_hint'.tr,
        onChanged: controller.onSearchChanged,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        suffixIcon: const Icon(Icons.tune_rounded, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SizedBox(
      height: 50,
      child: Obx(() {
        final currentFilter = controller.selectedFilter.value;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            final isSelected = currentFilter == filter;

            return ChoiceChip(
              label: Text(_filterLabel(filter)),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) {
                  controller.onFilterChanged(filter);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: theme.cardColor,
              labelStyle: TextStyle(
                color:
                    isSelected ? Colors.white : theme.colorScheme.onSurface,
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
            );
          },
        );
      }),
    );
  }

  Widget _buildProductGrid(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.favorites.isEmpty) {
        return Center(child: AppLoading(message: 'loading_products'.tr));
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.favorites.isEmpty) {
        return Center(
          child: AppError(
            message: controller.errorMessage.value,
            onRetry: controller.refreshFavorites,
          ),
        );
      }

      if (controller.favorites.isEmpty) {
        return Center(
          child: AppEmpty(
            message: 'no_favorites_found'.tr,
            icon: Icons.favorite_border_rounded,
            actionLabel: 'explore_catalog'.tr,
            onAction: () => Get.toNamed(AppRoutes.products),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFavorites,
        color: AppColors.primary,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 0.66,
          ),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final favorite = controller.favorites[index];
            return _buildProductCard(context, theme, favorite);
          },
        ),
      );
    });
  }

  Widget _buildProductCard(
    BuildContext context,
    ThemeData theme,
    Favorite favorite,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(
            '/products/${favorite.id}',
            arguments: favorite.id,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Favorite Badge
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: favorite.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.favorite_outline_rounded,
                      fallbackIconSize: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                    ),
                    Positioned(
                      top: AppDimensions.sm,
                      right: AppDimensions.sm,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => controller.toggleFavorite(
                            productId: favorite.id,
                            name: favorite.name,
                            price: favorite.price,
                            imageUrl: favorite.imageUrl,
                            category: favorite.category,
                            defaultIsFavorite: true,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.error,
                              size: AppDimensions.iconSm,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(AppDimensions.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      favorite.category ?? 'categories'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${favorite.price.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              if (!Get.isRegistered<CartController>()) {
                                CartBinding().dependencies();
                              }
                              Get.find<CartController>().addToCart(
                                productId: favorite.id,
                                quantity: 1,
                                productName: favorite.name,
                                unitPrice: favorite.price,
                                productImageUrl: favorite.imageUrl,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
