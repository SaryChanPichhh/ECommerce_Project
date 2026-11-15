import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../bindings/cart_binding.dart';
import '../controllers/cart_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    controller = Get.find<CartController>();
    controller.checkAuth();
  }

  Widget _buildCheckoutPanel() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Obx(() {
      final isLoggedIn = controller.isLoggedIn.value;
      final cart = controller.cart.value;
      if (!isLoggedIn || cart == null || !cart.hasSelectedItems) {
        return const SizedBox.shrink();
      }

      final totals = cart.totals;

      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppDimensions.lg,
          left: AppDimensions.lg,
          right: AppDimensions.lg,
          top: AppDimensions.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'enter_promocode'.tr,
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () {
                    Helpers.showWarning('promo_unavailable'.tr);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'subtotal'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: secondaryColor,
                  ),
                ),
                Text(
                  '\$${totals.subtotalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm + 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'shipping'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: secondaryColor,
                  ),
                ),
                Text(
                  '\$${totals.shippingAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0
                            ? theme.dividerColor.withValues(alpha: 0.7)
                            : Colors.transparent,
                        height: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total_amount'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totals.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),

            ElevatedButton(
              onPressed: () {
                Get.toNamed('/payment');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: Text(
                'checkout'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Scaffold(
      appBar: AppBar(
        title: Text('my_cart'.tr),
        actions: [
          Obx(() {
            final isLoggedIn = controller.isLoggedIn.value;
            final cart = controller.cart.value;
            if (!isLoggedIn || cart == null || cart.isEmpty) {
              return const SizedBox.shrink();
            }
            final allSelected = cart.items.every((i) => i.isSelected);
            return TextButton(
              onPressed: () => controller.toggleSelectAll(!allSelected),
              child: Text(
                allSelected ? 'deselect_all'.tr : 'select_all'.tr,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildCheckoutPanel(),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final isLoggedIn = controller.isLoggedIn.value;
        final cart = controller.cart.value;

        if (isLoading) {
          return const Center(child: AppLoading());
        }

        if (!isLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: secondaryColor,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'login_required'.tr,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'login_to_view_cart'.tr,
                    style: TextStyle(color: secondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl,
                        vertical: AppDimensions.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: Text('login'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        if (cart == null || cart.isEmpty) {
          return AppEmpty(
            icon: Icons.shopping_bag_outlined,
            message: 'cart_empty'.tr,
            actionLabel: 'explore_catalog'.tr,
            onAction: () => Get.toNamed(AppRoutes.products),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCart,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  side: BorderSide(
                    color: theme.dividerColor
                        .withValues(alpha: isDark ? 0.25 : 0.45),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.sm + 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: item.isSelected,
                        onChanged: (value) => controller.toggleItemSelection(
                          item.id,
                          value ?? false,
                        ),
                        activeColor: AppColors.primary,
                      ),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        child: AppNetworkImage(
                          imageUrl: item.productImageUrl,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.shopping_bag_outlined,
                          fallbackIconSize: 28,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'delete'.tr,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.error
                                        .withValues(alpha: 0.85),
                                  ),
                                  onPressed: () =>
                                      controller.removeItem(item.id),
                                ),
                              ],
                            ),
                            if (item.variantName != null &&
                                item.variantName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${'variant'.tr}: ${item.variantName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => controller.updateQuantity(
                                          item.id,
                                          item.quantity - 1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => controller.updateQuantity(
                                          item.id,
                                          item.quantity + 1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
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
            },
          ),
        );
      }),
    );
  }
}
