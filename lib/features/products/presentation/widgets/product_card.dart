import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../favorite/presentation/bindings/favorite_binding.dart';
import '../../../favorite/presentation/controllers/favorite_controller.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCartTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavoriteTap,
    this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);
    final isManageMode = onEdit != null || onDelete != null;
    final hasDiscount = product.compareAtPrice != null &&
        product.compareAtPrice! > product.price;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm + 2),
      elevation: isDark ? 1 : 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm + 4),
          child: Row(
            children: [
              // Product image
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      fallbackIcon: Icons.inventory_2_outlined,
                      fallbackIconSize: 28,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    if (product.quantity <= 0)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'out_of_stock'.tr,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null &&
                        product.category!.isNotEmpty) ...[
                      Text(
                        product.category!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (isManageMode) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: product.quantity > 0
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    product.quantity <= 0
                        ? 'out_of_stock'.tr
                        : '${'qty'.tr}${product.quantity}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: product.quantity > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
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
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'delete'.tr,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFavoriteAction(context, theme),
                    if (product.quantity <= 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          'out_of_stock'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'add_to_cart'.tr,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        onPressed: onAddToCartTap ??
                            () {
                              if (!Get.isRegistered<CartController>()) {
                                CartBinding().dependencies();
                              }
                              Get.find<CartController>().addToCart(
                                productId: product.id,
                                quantity: 1,
                                productName: product.name,
                                unitPrice: product.price,
                                productImageUrl: product.imageUrl,
                              );
                            },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteAction(BuildContext context, ThemeData theme) {
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    if (Get.isRegistered<FavoriteController>()) {
      final favController = Get.find<FavoriteController>();
      return Obx(() {
        final isFav = favController.isFavorite(
          product.id,
          defaultIsFavorite: product.isFavorite,
        );
        return IconButton(
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? AppColors.error : inactiveColor,
          ),
          onPressed: onFavoriteTap ??
              () => favController.toggleFavoriteProduct(product),
        );
      });
    }

    return IconButton(
      icon: Icon(
        product.isFavorite
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        color: product.isFavorite ? AppColors.error : inactiveColor,
      ),
      onPressed: onFavoriteTap ??
          () {
            if (!Get.isRegistered<FavoriteController>()) {
              FavoriteBinding().dependencies();
            }
            Get.find<FavoriteController>().toggleFavoriteProduct(product);
          },
    );
  }
}
