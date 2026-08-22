class Order {
  final String id;
  final String? customerId;
  final String? customerName;
  final double totalAmount;
  final String status;
  final String? notes;
  final List<OrderItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({required this.id, this.customerId, this.customerName, required this.totalAmount, this.status = 'pending', this.notes, this.items, this.createdAt, this.updatedAt});

  @override
  bool operator ==(Object other) => identical(this, other) || other is Order && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class OrderItem {
  final String id;
  final String productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({required this.id, required this.productId, this.productName, required this.quantity, required this.unitPrice, required this.totalPrice});
}
