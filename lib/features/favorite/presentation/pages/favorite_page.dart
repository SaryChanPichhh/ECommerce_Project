import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/favorite.dart';
import '../controllers/favorite_controller.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final favorites = List<Favorite>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favorite'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: AppTextField(
        hint: 'Search favorite...',
        onChanged: controller.onSearchChanged,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondaryLight,
        ),
        suffixIcon: const Icon(Icons.tune, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: Obx(() {
        // Access the value directly in the Obx block so GetX tracks it correctly
        final currentFilter = controller.selectedFilter.value;
        
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          scrollDirection: Axis.horizontal,
          itemCount: controller.filters.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppDimensions.sm),
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            final isSelected = currentFilter == filter;
            
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.onFilterChanged(filter);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.backgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.favorites.isEmpty) {
        return const Center(child: AppLoading());
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
        return const Center(
          child: AppEmpty(
            message: 'No favorites found',
            icon: Icons.favorite_border,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFavorites,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 0.75, // Adjust based on card height
          ),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final favorite = controller.favorites[index];
            return _buildProductCard(context, favorite);
          },
        ),
      );
    });
  }

  Widget _buildProductCard(BuildContext context, Favorite favorite) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Favorite Badge
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                  width: double.infinity,
                  child: favorite.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.radiusLg),
                          ),
                          child: Image.network(
                            favorite.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                ),
                Positioned(
                  top: AppDimensions.sm,
                  right: AppDimensions.sm,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(AppDimensions.xs),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.error,
                      size: AppDimensions.iconSm,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  favorite.category ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  '\$${favorite.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
