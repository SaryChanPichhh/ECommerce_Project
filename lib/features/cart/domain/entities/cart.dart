class Cart {
  final String id;
  final String status;
  final List<CartItem> items;
  final CartTotals totals;

  const Cart({
    required this.id,
    this.status = 'active',
    this.items = const [],
    required this.totals,
  });

  bool get isEmpty => items.isEmpty;
  bool get hasSelectedItems => items.any((item) => item.isSelected);
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final bool isSelected;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.variantId,
    this.variantName,
    this.quantity = 1,
    required this.unitPrice,
    required this.lineTotal,
    this.isSelected = true,
  });

  CartItem copyWith({
    int? quantity,
    bool? isSelected,
  }) {
    final newQty = quantity ?? this.quantity;
    return CartItem(
      id: id,
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      variantId: variantId,
      variantName: variantName,
      quantity: newQty,
      unitPrice: unitPrice,
      lineTotal: unitPrice * newQty,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class CartTotals {
  final int selectedItemCount;
  final double subtotalAmount;
  final double shippingAmount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;

  const CartTotals({
    this.selectedItemCount = 0,
    this.subtotalAmount = 0.0,
    this.shippingAmount = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.currency = 'USD',
  });
}
