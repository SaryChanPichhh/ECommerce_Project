import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../favorite/presentation/bindings/favorite_binding.dart';
import '../../../favorite/presentation/controllers/favorite_controller.dart';
import '../../domain/entities/product.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCartTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCartTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.62);
    final hasDiscount = product.compareAtPrice != null &&
        product.compareAtPrice! > product.price;
    final discountPercent = hasDiscount
        ? ((product.compareAtPrice! - product.price) /
                product.compareAtPrice! *
                100)
            .round()
        : 0;

    return Card(
      elevation: isDark ? 1 : 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Badges
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.inventory_2_outlined,
                    fallbackIconSize: 38,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.05),
                  ),

                  // Subtle bottom edge gradient when out of stock
                  if (product.quantity <= 0)
                    Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusRound),
                        ),
                        child: Text(
                          'out_of_stock'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Discount / Sale Badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                  // Heart Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildHeartButton(context, theme),
                  ),

                  // Admin Edit/Delete Menu (if admin callbacks passed)
                  if (onEdit != null || onDelete != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Text('edit'.tr),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outlined,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'delete'.tr,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.category != null &&
                      product.category!.trim().isNotEmpty) ...[
                    Text(
                      product.category!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Name
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Rating & Sold
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        (product.ratingAverage > 0 ? product.ratingAverage : 4.8)
                            .toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '• ${product.soldCount > 0 ? product.soldCount : 24}+ ${'sold'.tr}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price & Quick Cart Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (product.quantity > 0 && onAddToCartTap != null)
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onAddToCartTap,
                            borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildHeartButton(BuildContext context, ThemeData theme) {
    final secondaryIconColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.65);

    if (Get.isRegistered<FavoriteController>()) {
      final favController = Get.find<FavoriteController>();
      return Obx(() {
        final isFav = favController.isFavorite(
          product.id,
          defaultIsFavorite: product.isFavorite,
        );
        return _heartCircle(
          theme: theme,
          isFav: isFav,
          inactiveColor: secondaryIconColor,
          onTap: onFavoriteTap ??
              () => favController.toggleFavoriteProduct(product),
        );
      });
    }

    return _heartCircle(
      theme: theme,
      isFav: product.isFavorite,
      inactiveColor: secondaryIconColor,
      onTap: onFavoriteTap ??
          () {
            if (!Get.isRegistered<FavoriteController>()) {
              FavoriteBinding().dependencies();
            }
            Get.find<FavoriteController>().toggleFavoriteProduct(product);
          },
    );
  }

  Widget _heartCircle({
    required ThemeData theme,
    required bool isFav,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
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
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: isFav ? AppColors.error : inactiveColor,
          ),
        ),
      ),
    );
  }
}
