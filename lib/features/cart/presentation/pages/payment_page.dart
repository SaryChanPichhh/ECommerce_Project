import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int selectedPaymentIndex = 0;

  // Dummy checked cart items passed from cart page
  final List<Map<String, dynamic>> checkedItems = [
    {
      'name': 'Wireless Headphones',
      'color': 'Red',
      'colorValue': Colors.red,
      'price': 120.0,
      'quantity': 1,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Smart Watch',
      'color': 'Black',
      'colorValue': Colors.black,
      'price': 250.0,
      'quantity': 2,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  // Delivery address state
  String addressName = 'Home';
  String addressDetail = '123 Street, Phnom Penh, Cambodia';

  double get subtotal {
    double total = 0;
    for (var item in checkedItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  double get shipping => 15.0;
  double get totalAmount => subtotal + shipping;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Address Section â”€â”€
            _buildAddressSection(),
            const SizedBox(height: AppDimensions.lg),

            // â”€â”€ Products Section â”€â”€
            _buildProductsSection(),
            const SizedBox(height: AppDimensions.lg),

            // â”€â”€ Payment Method Section â”€â”€
            _buildPaymentMethodSection(),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // ADDRESS SECTION: Row(Address, Edit) + Row(Map, Column(name, address))
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAddressSection() {
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
          // Row: "Address" + "Edit" button
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
                  // Navigate to edit address page and wait for result
                  final result = await Get.toNamed('/edit-address');
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      addressName = result['name'] ?? addressName;
                      addressDetail = result['address'] ?? addressDetail;
                    });
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Row: Map placeholder + Column(name, address)
          Row(
            children: [
              // Google Map placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Stack(
                    children: [
                      Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Column: name + address
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
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // PRODUCTS SECTION
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Products" title with count
        Text(
          'Products (${checkedItems.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.sm),

        // List of product cards
        ...checkedItems.map((item) => _buildProductCard(item)),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            // Image (centerLeft)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                image: DecorationImage(
                  image: NetworkImage(item['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),

            // Column: name + Row(color, price)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Row: Color : red with container  |  Price (space between)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Color : ${item['color']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: item['colorValue'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 15,
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // PAYMENT METHOD SECTION
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildPaymentMethodSection() {
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
          // Title
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Payment method cards (ABA, Bakong)
          ...paymentMethods.asMap().entries.map((entry) {
            final index = entry.key;
            final method = entry.value;
            final isSelected = selectedPaymentIndex == index;

            return GestureDetector(
              onTap: () => setState(() => selectedPaymentIndex = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (method['color'] as Color).withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: isSelected ? method['color'] as Color : Colors.grey.shade300,
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
              onPressed: () {
                Get.snackbar(
                  'Payment',
                  'Processing payment via ${paymentMethods[selectedPaymentIndex]['name']}...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: const Text(
                'Checkout Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
