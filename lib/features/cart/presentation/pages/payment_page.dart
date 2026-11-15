import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/map_location_service.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../bindings/cart_binding.dart';
import '../controllers/cart_controller.dart';
import '../widgets/aba_logo.dart';

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
      'id': 'aba',
      'name': 'aba_pay',
      'desc': 'aba_pay_desc',
      'color': const Color(0xFF005E7C),
      'isAba': true,
    },
    {
      'id': 'cash',
      'name': 'cash',
      'desc': 'cash_desc',
      'color': const Color(0xFF10B981),
      'isAba': false,
      'icon': Icons.payments_rounded,
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
            _buildAddressSection(),
            const SizedBox(height: AppDimensions.lg),
            _buildProductsSection(),
            const SizedBox(height: AppDimensions.lg),
            _buildPaymentMethodSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Obx(() {
      final addr = controller.selectedAddress.value;
      final addressName = addr?.label ?? addr?.recipientName ?? 'Home';
      final addressDetail =
          addr?.fullAddress ?? '123 Russian Federation Blvd, Phnom Penh';

      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
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
                  'address'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
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
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'edit'.tr,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
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
                    color: const Color(0xFFE8F5E9),
                    child: Builder(
                      builder: (context) {
                        final lat = addr?.latitude ?? 11.5684;
                        final lng = addr?.longitude ?? 104.8906;
                        final googleStaticUrl =
                            'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=160x160&scale=2&markers=color:red%7C$lat,$lng&key=${AppConstants.googleMapsApiKey}';
                        final osmTileUrl = MapLocationService.getOsmTileUrl(
                          lat,
                          lng,
                          zoom: 15,
                        );

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            AppNetworkImage(
                              imageUrl: googleStaticUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              headers: MapLocationService.osmHeaders,
                              errorWidget: AppNetworkImage(
                                imageUrl: osmTileUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                headers: MapLocationService.osmHeaders,
                                errorWidget: _mapPlaceholder(),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ],
                        );
                      },
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        addressDetail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryColor,
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

  Widget _mapPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.map_outlined,
          size: 40,
          color: Colors.green.withValues(alpha: 0.35),
        ),
        const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 28,
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Obx(() {
      final cart = controller.cart.value;
      final selectedItems =
          cart?.items.where((item) => item.isSelected).toList() ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'products'.tr} (${selectedItems.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          if (selectedItems.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                side: BorderSide(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Center(
                  child: Text('no_items_selected'.tr),
                ),
              ),
            )
          else
            ...selectedItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  side: BorderSide(
                    color: theme.dividerColor
                        .withValues(alpha: isDark ? 0.25 : 0.45),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        child: AppNetworkImage(
                          imageUrl: item.productImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.shopping_bag_outlined,
                          fallbackIconSize: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: theme.textTheme.titleSmall?.copyWith(
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
                                  '${'qty'.tr}${item.quantity}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
            }),
        ],
      );
    });
  }

  Widget _buildPaymentMethodSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Obx(() {
      final cart = controller.cart.value;
      final totals = cart?.totals;
      final totalAmount = totals?.totalAmount ?? 0.0;

      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'payment_method'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            ...paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final methodColor = method['color'] as Color;
              final isSelected = selectedPaymentIndex == index;
              final isAba = method['isAba'] as bool? ?? false;

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
                        ? methodColor.withValues(alpha: 0.08)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isSelected
                          ? methodColor
                          : theme.dividerColor.withValues(alpha: 0.5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isAba)
                        const AbaLogo(size: 44, borderRadius: 12)
                      else
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: methodColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          child: Icon(
                            method['icon'] as IconData? ?? Icons.payments_rounded,
                            color: methodColor,
                            size: 24,
                          ),
                        ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (method['name'] as String).tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected ? methodColor : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (method['desc'] as String).tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? methodColor : theme.dividerColor,
                            width: 2,
                          ),
                          color: isSelected ? methodColor : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
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
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isCheckingOut.value
                    ? null
                    : () async {
                        final selectedMethod =
                            paymentMethods[selectedPaymentIndex]['id'] as String;
                        final success = await controller.checkout(
                          paymentMethod:
                              selectedMethod == 'cash' ? 'Cash' : 'ABA',
                        );
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
                    : Text(
                        'checkout_now'.tr,
                        style: const TextStyle(
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
