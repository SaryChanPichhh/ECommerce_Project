import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({required super.id, super.customerId, super.customerName, required super.totalAmount, super.status, super.notes, super.items, super.createdAt, super.updatedAt});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      items: json['items'] != null ? (json['items'] as List).map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({required super.id, required super.productId, super.productName, required super.quantity, required super.unitPrice, required super.totalPrice});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
