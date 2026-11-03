import '../../domain/entities/order.dart';

double _parseDouble(dynamic val, [double fallback = 0.0]) {
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? fallback;
  return fallback;
}

DateTime? _parseDate(dynamic val) {
  if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
  return null;
}

// ──────────────────────────────────────────────────────────
// Request Models (per lib/docs/order_process.md)
// ──────────────────────────────────────────────────────────

/// Step 6: `POST /api/v1/customer/orders/`
class CreateOrderRequestModel {
  final String cartId;
  final String shippingAddressId;
  final String idempotencyKey;

  const CreateOrderRequestModel({
    required this.cartId,
    required this.shippingAddressId,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
        'cart_id': cartId,
        'shipping_address_id': shippingAddressId,
        'idempotency_key': idempotencyKey,
      };
}

/// Step 8 & Payment Failure Flow: `POST /api/v1/customer/orders/payment/`
class OrderPaymentRequestModel {
  final String idempotencyKey;
  final List<String> orderIds;
  final String? simulateOutcome;
  final String? failureReason;

  const OrderPaymentRequestModel({
    required this.idempotencyKey,
    required this.orderIds,
    this.simulateOutcome,
    this.failureReason,
  });

  Map<String, dynamic> toJson() => {
        'idempotency_key': idempotencyKey,
        'order_ids': orderIds,
        if (simulateOutcome != null && simulateOutcome!.isNotEmpty)
          'simulate_outcome': simulateOutcome,
        if (failureReason != null && failureReason!.isNotEmpty)
          'failure_reason': failureReason,
      };
}

/// Step 16: `POST /api/v1/customer/shipments/{shipment_id}/confirm-delivery`
class ConfirmDeliveryRequestModel {
  final String? note;

  const ConfirmDeliveryRequestModel({this.note});

  Map<String, dynamic> toJson() => {
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

// ──────────────────────────────────────────────────────────
// Response Models (per lib/docs/order_process.md)
// ──────────────────────────────────────────────────────────

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    super.orderNumber,
    super.customerId,
    super.customerName,
    super.customerPhone,
    super.customerEmail,
    super.storeId,
    super.storeName,
    super.shippingAddressId,
    super.shippingAddressText,
    super.subtotalAmount,
    super.shippingAmount,
    super.discountAmount,
    super.taxAmount,
    required super.totalAmount,
    super.currency,
    super.status,
    super.notes,
    super.itemCount,
    super.items,
    super.payment,
    super.shipments,
    super.statusHistory,
    super.createdAt,
    super.updatedAt,
    super.cancelledAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final parsedTotal = _parseDouble(json['total_amount'] ?? json['total']);
    final parsedSubtotal =
        _parseDouble(json['subtotal_amount'], parsedTotal);
    final parsedShipping = _parseDouble(json['shipping_amount']);
    final parsedDiscount = _parseDouble(json['discount_amount']);
    final parsedTax = _parseDouble(json['tax_amount']);

    String? storeId;
    String? storeName;
    if (json['store'] is Map) {
      final storeMap = json['store'] as Map;
      storeId = storeMap['id']?.toString();
      storeName = storeMap['name']?.toString();
    } else {
      storeId = json['store_id']?.toString();
      storeName = json['store_name']?.toString();
    }

    String? customerName = json['customer_name']?.toString();
    String? customerPhone =
        json['customer_phone']?.toString() ?? json['phone_number']?.toString();
    String? customerEmail =
        json['customer_email']?.toString() ?? json['email']?.toString();
    if (json['customer'] is Map) {
      final custMap = json['customer'] as Map;
      customerName ??= custMap['name']?.toString() ??
          '${custMap['first_name'] ?? ''} ${custMap['last_name'] ?? ''}'.trim();
      customerPhone ??=
          custMap['phone_number']?.toString() ?? custMap['phone']?.toString();
      customerEmail ??= custMap['email']?.toString();
    }
    customerName = (customerName != null && customerName.isNotEmpty)
        ? customerName
        : storeName;

    String? shippingAddressText = json['shipping_address_text']?.toString();
    if (shippingAddressText == null && json['shipping_address'] is Map) {
      final addr = json['shipping_address'] as Map;
      shippingAddressText = [
        addr['address_line_1'] ?? addr['street'],
        addr['city'],
        addr['province'] ?? addr['state'],
        addr['country'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    final itemsList = json['items'] is List
        ? (json['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(OrderItemModel.fromJson)
            .toList()
        : null;

    final paymentObj = json['payment'] is Map<String, dynamic>
        ? OrderPaymentModel.fromJson(json['payment'] as Map<String, dynamic>)
        : null;

    final shipmentsList = json['shipments'] is List
        ? (json['shipments'] as List)
            .whereType<Map<String, dynamic>>()
            .map(OrderShipmentModel.fromJson)
            .toList()
        : null;

    final historyList = json['status_history'] is List
        ? (json['status_history'] as List)
            .whereType<Map<String, dynamic>>()
            .map(OrderStatusHistoryModel.fromJson)
            .toList()
        : null;

    return OrderModel(
      id: json['id']?.toString() ?? json['order_id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString(),
      customerId:
          json['customer_id']?.toString() ?? json['user_id']?.toString(),
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      storeId: storeId,
      storeName: storeName,
      shippingAddressId: json['shipping_address_id']?.toString(),
      shippingAddressText: shippingAddressText,
      subtotalAmount: parsedSubtotal,
      shippingAmount: parsedShipping,
      discountAmount: parsedDiscount,
      taxAmount: parsedTax,
      totalAmount: parsedTotal,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? OrderStatus.pending,
      notes: json['notes']?.toString(),
      itemCount: json['item_count'] as int? ?? itemsList?.length,
      items: itemsList,
      payment: paymentObj,
      shipments: shipmentsList,
      statusHistory: historyList,
      createdAt: _parseDate(json['placed_at'] ?? json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    super.productVariantId,
    super.productName,
    super.variantName,
    super.sku,
    super.productImageUrl,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] as int? ?? 1;
    final parsedUnitPrice = _parseDouble(
      json['unit_price'] ?? json['unit_price_snapshot'] ?? json['price'],
    );
    final parsedTotal = _parseDouble(
      json['line_total'] ?? json['total_price'],
      parsedUnitPrice * qty,
    );

    String? imgUrl = json['primary_image_url']?.toString() ??
        json['product_image_url']?.toString() ??
        json['image_url']?.toString();
    if (imgUrl == null && json['product'] is Map) {
      final prodMap = json['product'] as Map;
      imgUrl = prodMap['primary_image_url']?.toString() ??
          prodMap['image_url']?.toString();
    }

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productVariantId: json['product_variant_id']?.toString(),
      productName:
          json['product_name']?.toString() ?? json['name']?.toString(),
      variantName: json['variant_name']?.toString(),
      sku: json['sku']?.toString(),
      productImageUrl: imgUrl,
      quantity: qty,
      unitPrice: parsedUnitPrice,
      totalPrice: parsedTotal,
    );
  }
}

class OrderPaymentModel extends OrderPayment {
  const OrderPaymentModel({
    required super.id,
    super.orderId,
    super.batchId,
    required super.status,
    required super.amount,
    super.currency,
    super.provider,
    super.providerReference,
    super.paidAt,
    super.refundedAt,
    super.failureReason,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      batchId: json['batch_id']?.toString() ??
          json['payment_batch_id']?.toString(),
      status: json['status']?.toString() ?? PaymentStatus.pending,
      amount: _parseDouble(json['amount'] ?? json['total_amount']),
      currency: json['currency']?.toString() ?? 'USD',
      provider: json['provider']?.toString(),
      providerReference: json['provider_reference']?.toString(),
      paidAt: _parseDate(json['paid_at']),
      refundedAt: _parseDate(json['refunded_at']),
      failureReason: json['failure_reason']?.toString(),
    );
  }
}

class OrderPaymentBatchModel extends OrderPaymentBatch {
  const OrderPaymentBatchModel({
    required super.id,
    super.idempotencyKey,
    required super.status,
    required super.totalAmount,
    super.currency,
    super.payments,
    super.orders,
    super.paidAt,
    super.failureReason,
  });

  factory OrderPaymentBatchModel.fromJson(Map<String, dynamic> json) {
    final batchMap = json['batch'] is Map<String, dynamic>
        ? json['batch'] as Map<String, dynamic>
        : json;

    final rawPayments = json['payments'] ??
        json['child_payments'] ??
        batchMap['payments'] ??
        batchMap['child_payments'];
    final paymentsList = rawPayments is List
        ? rawPayments
            .whereType<Map<String, dynamic>>()
            .map(OrderPaymentModel.fromJson)
            .toList()
        : <OrderPaymentModel>[];

    final rawOrders = json['orders'] ?? batchMap['orders'];
    final ordersList = rawOrders is List
        ? rawOrders
            .whereType<Map<String, dynamic>>()
            .map(OrderModel.fromJson)
            .toList()
        : <OrderModel>[];

    return OrderPaymentBatchModel(
      id: batchMap['id']?.toString() ?? '',
      idempotencyKey: batchMap['idempotency_key']?.toString(),
      status: batchMap['status']?.toString() ?? PaymentStatus.succeeded,
      totalAmount:
          _parseDouble(batchMap['total_amount'] ?? batchMap['amount']),
      currency: batchMap['currency']?.toString() ?? 'USD',
      payments: paymentsList,
      orders: ordersList,
      paidAt: _parseDate(batchMap['paid_at']),
      failureReason: batchMap['failure_reason']?.toString(),
    );
  }
}

class OrderStatusHistoryModel extends OrderStatusHistory {
  const OrderStatusHistoryModel({
    required super.id,
    super.fromStatus,
    required super.toStatus,
    super.note,
    super.createdAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id']?.toString() ?? '',
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString() ??
          json['status']?.toString() ??
          OrderStatus.pending,
      note: json['note']?.toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class OrderShipmentModel extends OrderShipment {
  const OrderShipmentModel({
    required super.id,
    super.orderId,
    super.carrierName,
    super.trackingNumber,
    super.status,
    super.note,
    super.confirmedBy,
    super.deliveryNote,
    super.createdAt,
    super.shippedAt,
    super.deliveredAt,
    super.events,
  });

  factory OrderShipmentModel.fromJson(Map<String, dynamic> json) {
    final eventsList = json['events'] is List
        ? (json['events'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ShipmentEventModel.fromJson)
            .toList()
        : <ShipmentEventModel>[];

    return OrderShipmentModel(
      id: json['id']?.toString() ?? json['shipment_id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      carrierName:
          json['carrier_name']?.toString() ?? json['carrier']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      status: json['status']?.toString() ?? ShipmentStatus.pending,
      note: json['note']?.toString(),
      confirmedBy: json['confirmed_by']?.toString(),
      deliveryNote: json['delivery_note']?.toString(),
      createdAt: _parseDate(json['created_at']),
      shippedAt: _parseDate(json['shipped_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      events: eventsList,
    );
  }
}

class ShipmentEventModel extends ShipmentEvent {
  const ShipmentEventModel({
    required super.id,
    required super.status,
    super.location,
    super.description,
    super.eventTime,
  });

  factory ShipmentEventModel.fromJson(Map<String, dynamic> json) {
    return ShipmentEventModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? ShipmentStatus.pending,
      location: json['location']?.toString(),
      description:
          json['description']?.toString() ?? json['note']?.toString(),
      eventTime: _parseDate(json['event_time'] ?? json['created_at']),
    );
  }
}
