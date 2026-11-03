/// Canonical order statuses defined in `lib/docs/order_process.md`.
abstract class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String processing = 'processing';
  static const String shipped = 'shipped';
  static const String delivered = 'delivered';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String failed = 'failed';
}

/// Canonical shipment statuses defined in `lib/docs/order_process.md`.
abstract class ShipmentStatus {
  static const String pending = 'pending';
  static const String packed = 'packed';
  static const String inTransit = 'in_transit';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
}

/// Canonical payment statuses defined in `lib/docs/order_process.md`.
abstract class PaymentStatus {
  static const String pending = 'pending';
  static const String succeeded = 'succeeded';
  static const String failed = 'failed';
  static const String partiallyRefunded = 'partially_refunded';
  static const String refunded = 'refunded';
}

class Order {
  final String id;
  final String? orderNumber;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? storeId;
  final String? storeName;
  final String? shippingAddressId;
  final String? shippingAddressText;
  final double subtotalAmount;
  final double shippingAmount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String status;
  final String? notes;
  final int? itemCount;
  final List<OrderItem>? items;
  final OrderPayment? payment;
  final List<OrderShipment>? shipments;
  final List<OrderStatusHistory>? statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;

  const Order({
    required this.id,
    this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.storeId,
    this.storeName,
    this.shippingAddressId,
    this.shippingAddressText,
    this.subtotalAmount = 0.0,
    this.shippingAmount = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.currency = 'USD',
    this.status = OrderStatus.pending,
    this.notes,
    this.itemCount,
    this.items,
    this.payment,
    this.shipments,
    this.statusHistory,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
  });

  /// Terminal statuses (`delivered`, `completed`, `cancelled`, `failed`) belong to Order History.
  bool get isTerminal {
    final s = status.toLowerCase();
    return s == OrderStatus.delivered ||
        s == OrderStatus.completed ||
        s == OrderStatus.cancelled ||
        s == OrderStatus.failed;
  }

  /// Active orders (`pending`, `confirmed`, `processing`, `shipped`).
  bool get isActive => !isTerminal;

  /// Per `order_process.md`: Cancellation is allowed only while the order is `pending` or `confirmed`.
  bool get canCustomerCancel {
    final s = status.toLowerCase();
    return s == OrderStatus.pending || s == OrderStatus.confirmed;
  }

  /// Per `order_process.md` Step 8: Customer can complete payment while the order is `pending` and unpaid.
  bool get canPay {
    final s = status.toLowerCase();
    if (s != OrderStatus.pending) return false;
    final pStatus = payment?.status.toLowerCase();
    return pStatus != PaymentStatus.succeeded;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Order && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class OrderItem {
  final String id;
  final String productId;
  final String? productVariantId;
  final String? productName;
  final String? variantName;
  final String? sku;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.productId,
    this.productVariantId,
    this.productName,
    this.variantName,
    this.sku,
    this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class OrderPayment {
  final String id;
  final String? orderId;
  final String? batchId;
  final String status;
  final double amount;
  final String currency;
  final String? provider;
  final String? providerReference;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final String? failureReason;

  const OrderPayment({
    required this.id,
    this.orderId,
    this.batchId,
    required this.status,
    required this.amount,
    this.currency = 'USD',
    this.provider,
    this.providerReference,
    this.paidAt,
    this.refundedAt,
    this.failureReason,
  });
}

class OrderPaymentBatch {
  final String id;
  final String? idempotencyKey;
  final String status;
  final double totalAmount;
  final String currency;
  final List<OrderPayment> payments;
  final List<Order> orders;
  final DateTime? paidAt;
  final String? failureReason;

  const OrderPaymentBatch({
    required this.id,
    this.idempotencyKey,
    required this.status,
    required this.totalAmount,
    this.currency = 'USD',
    this.payments = const [],
    this.orders = const [],
    this.paidAt,
    this.failureReason,
  });
}

class OrderStatusHistory {
  final String id;
  final String? fromStatus;
  final String toStatus;
  final String? note;
  final DateTime? createdAt;

  const OrderStatusHistory({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.note,
    this.createdAt,
  });
}

class OrderShipment {
  final String id;
  final String? orderId;
  final String? carrierName;
  final String? trackingNumber;
  final String status;
  final String? note;
  final String? confirmedBy;
  final String? deliveryNote;
  final DateTime? createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<ShipmentEvent> events;

  const OrderShipment({
    required this.id,
    this.orderId,
    this.carrierName,
    this.trackingNumber,
    this.status = ShipmentStatus.pending,
    this.note,
    this.confirmedBy,
    this.deliveryNote,
    this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.events = const [],
  });

  /// Per `order_process.md` Step 16: Customer can confirm delivery when shipment is `out_for_delivery`.
  bool get canConfirmDelivery =>
      status.toLowerCase() == ShipmentStatus.outForDelivery;
}

class ShipmentEvent {
  final String id;
  final String status;
  final String? location;
  final String? description;
  final DateTime? eventTime;

  const ShipmentEvent({
    required this.id,
    required this.status,
    this.location,
    this.description,
    this.eventTime,
  });
}
