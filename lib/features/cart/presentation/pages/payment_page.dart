import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bindings/cart_binding.dart';
import '../controllers/cart_controller.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final CartController controller;
  int selectedPaymentIndex = 0;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'ABA',
      'icon': Icons.account_balance,
      'color': const Color(0xFF005B9F),
    },
    {
      'name': 'Bakong',
      'icon': Icons.phone_android,
      'color': const Color(0xFFD4272D),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    controller = Get.find<CartController>();
    controller.refreshCheckoutPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            _buildAddressSection(),
            const SizedBox(height: AppDimensions.lg),

            // Products Section
            _buildProductsSection(),
            const SizedBox(height: AppDimensions.lg),

            // Payment Method Section
            _buildPaymentMethodSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Obx(() {
      final addr = controller.selectedAddress.value;
      final addressName = addr?.label ?? addr?.recipientName ?? 'Home';
      final addressDetail = addr?.fullAddress ?? '123 Russian Federation Blvd, Phnom Penh';

      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Get.toNamed(
                      '/edit-address',
                      arguments: {
                        'name': addressName,
                        'address': addressDetail,
                        'latitude': addr?.latitude,
                        'longitude': addr?.longitude,
                      },
                    );
                    if (result != null && result is Map) {
                      await controller.saveAddress(
                        name: result['name']?.toString() ?? 'Home',
                        address: result['address']?.toString() ?? '',
                        latitude: result['latitude'] as double?,
                        longitude: result['longitude'] as double?,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: (addr?.latitude != null && addr?.longitude != null)
                        ? Image.network(
                            'https://maps.googleapis.com/maps/api/staticmap?center=${addr!.latitude},${addr.longitude}&zoom=15&size=160x160&scale=2&markers=color:red%7C${addr.latitude},${addr.longitude}&key=${AppConstants.googleMapsApiKey}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.network(
                              'https://staticmap.openstreetmap.de/staticmap.php?center=${addr.latitude},${addr.longitude}&zoom=15&size=160x160&maptype=mapnik',
                              fit: BoxFit.cover,
                              errorBuilder: (context2, error2, stackTrace2) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 40,
                                    color: Colors.green.withValues(alpha: 0.3),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 40,
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 28,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        addressDetail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductsSection() {
    return Obx(() {
      final cart = controller.cart.value;
      final selectedItems =
          cart?.items.where((item) => item.isSelected).toList() ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products (${selectedItems.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          if (selectedItems.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppDimensions.md),
                child: Center(
                  child: Text('No items selected for checkout'),
                ),
              ),
            )
          else
            ...selectedItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
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

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
            }),
        ],
      );
    });
  }

  Widget _buildPaymentMethodSection() {
    return Obx(() {
      final cart = controller.cart.value;
      final totals = cart?.totals;
      final totalAmount = totals?.totalAmount ?? 0.0;

      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),

            ...paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isSelected = selectedPaymentIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (method['color'] as Color).withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isSelected
                          ? method['color'] as Color
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Text(
                          method['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? method['color'] as Color : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: method['color'] as Color),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppDimensions.md),

            // Dash line
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0 ? Colors.grey.shade400 : Colors.transparent,
                        height: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.md),

            // Total Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),

            // Checkout Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isCheckingOut.value
                    ? null
                    : () async {
                        final success = await controller.checkout();
                        if (success) {
                          Get.offAllNamed('/main');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: controller.isCheckingOut.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Checkout Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
