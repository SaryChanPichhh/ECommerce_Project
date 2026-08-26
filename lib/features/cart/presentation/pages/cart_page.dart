import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy data for cart items
  final List<Map<String, dynamic>> cartItems = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'color': 'Red',
      'colorValue': Colors.red,
      'price': 120.0,
      'quantity': 1,
      'isChecked': false,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': '2',
      'name': 'Smart Watch',
      'color': 'Black',
      'colorValue': Colors.black,
      'price': 250.0,
      'quantity': 2,
      'isChecked': false,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  bool get hasCheckedItems => cartItems.any((item) => item['isChecked'] == true);

  Widget _buildCheckoutPanel() {
    // Calculate totals based on checked items
    double subtotal = 0;
    for (var item in cartItems) {
      if (item['isChecked']) {
        subtotal += item['price'] * item['quantity'];
      }
    }
    double shipping = subtotal > 0 ? 15.0 : 0.0;
    double total = subtotal + shipping;

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
              const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          
          // Shipping Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('\$${shipping.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
              const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
            child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onCheckboxChanged(int index, bool? value) {
    setState(() {
      cartItems[index]['isChecked'] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      bottomNavigationBar: hasCheckedItems ? _buildCheckoutPanel() : null,
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
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
                          value: item['isChecked'],
                          onChanged: (value) => _onCheckboxChanged(index, value),
                          activeColor: AppColors.primary,
                        ),
                        
                        // Image of product
                        Container(
                          width: 80,
                          height: 80,
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
                        
                        // Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item Name
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              
                              // Color : red + container of color
                              Row(
                                children: [
                                  Text(
                                    'Color : ${item['color']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: item['colorValue'],
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
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
                                          onTap: () {
                                            if (item['quantity'] > 1) {
                                              setState(() {
                                                item['quantity']--;
                                              });
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(Icons.remove, size: 16),
                                          ),
                                        ),
                                        Text(
                                          '${item['quantity']}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              item['quantity']++;
                                            });
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(Icons.add, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Price calculated based on QTY
                                  Text(
                                    '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                    style: TextStyle(
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
  }
}
