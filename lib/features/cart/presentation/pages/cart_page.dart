import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/cart_controller.dart';
import '../bindings/cart_binding.dart';

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
    return Obx(() {
      final isLoggedIn = controller.isLoggedIn.value;
      final cart = controller.cart.value;
      if (!isLoggedIn || cart == null || !cart.hasSelectedItems) {
        return const SizedBox.shrink();
      }

      final totals = cart.totals;

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            // Promo Code TextField
            TextField(
              decoration: InputDecoration(
                hintText: 'enter your promocode',
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Apply promo code action
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            // Subtotal Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '\$${totals.subtotalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Shipping Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shipping',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '\$${totals.shippingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Dash Line
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0 ? Colors.grey : Colors.transparent,
                        height: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.md),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totals.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),

            // Checkout Button
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
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                allSelected ? 'Deselect All' : 'Select All',
                style: const TextStyle(color: AppColors.primary),
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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'login_required'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'login_to_view_cart'.tr,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl,
                        vertical: AppDimensions.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
          return Center(child: Text('cart_empty'.tr));
        }

        return RefreshIndicator(
          onRefresh: controller.loadCart,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Checkbox (centerLeft)
                      Checkbox(
                        value: item.isSelected,
                        onChanged: (value) =>
                            controller.toggleItemSelection(item.id, value ?? false),
                        activeColor: AppColors.primary,
                      ),

                      // Image of product
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (item.productImageUrl != null &&
                                item.productImageUrl!.isNotEmpty)
                            ? Image.network(
                                item.productImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: AppDimensions.md),

                      // Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Name
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Variant/Color if present
                            if (item.variantName != null &&
                                item.variantName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Variant : ${item.variantName}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            // Row: minus, value, add AND price based on QTY
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Quantity Controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => controller.updateQuantity(
                                          item.id,
                                          item.quantity - 1,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => controller.updateQuantity(
                                          item.id,
                                          item.quantity + 1,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Price calculated based on QTY
                                Text(
                                  '\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
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
