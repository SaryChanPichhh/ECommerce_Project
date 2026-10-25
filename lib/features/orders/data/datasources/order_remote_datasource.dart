import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status});
  Future<OrderModel> getOrder(String id);
  Future<List<OrderModel>> createOrder({
    required String cartId,
    required String shippingAddressId,
    String? idempotencyKey,
    List<OrderItemModel>? fallbackItems,
    double? fallbackTotal,
    String? fallbackStoreName,
  });
  Future<OrderPaymentBatchModel> payOrders({
    required List<String> orderIds,
    String? idempotencyKey,
    String? simulateOutcome,
    String? failureReason,
  });
  Future<OrderPaymentModel> getOrderPayment(String orderId);
  Future<OrderModel> cancelOrder(String id);
  Future<List<OrderStatusHistoryModel>> getOrderStatusHistory(String orderId);
  Future<List<OrderShipmentModel>> getOrderShipments(String orderId);
  Future<OrderShipmentModel> getShipment(String shipmentId);
  Future<List<ShipmentEventModel>> getShipmentEvents(String shipmentId);
  Future<OrderShipmentModel> confirmDelivery(
    String shipmentId, {
    String? note,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  OrderRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  static final _localCreatedOrders = <OrderModel>[];

  static final _mockOrders = <OrderModel>[
    OrderModel(
      id: 'ORD-001',
      orderNumber: 'ORD-E3F78A9C12B4',
      customerName: 'Kutuku Official Store',
      storeName: 'Kutuku Official Store',
      subtotalAmount: 150.0,
      totalAmount: 150.0,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: const [
        OrderItemModel(
          id: 'item1',
          productId: 'p1',
          productName: 'Laptop',
          quantity: 1,
          unitPrice: 150.0,
          totalPrice: 150.0,
        ),
      ],
    ),
    OrderModel(
      id: 'ORD-002',
      orderNumber: 'ORD-B2A91D4C33EE',
      customerName: 'SETEC Gadgets',
      storeName: 'SETEC Gadgets',
      subtotalAmount: 45.0,
      totalAmount: 45.0,
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      items: const [
        OrderItemModel(
          id: 'item2',
          productId: 'p2',
          productName: 'Mouse',
          quantity: 2,
          unitPrice: 22.5,
          totalPrice: 45.0,
        ),
      ],
    ),
  ];

  @override
  Future<List<OrderModel>> getOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (page != null) qp['page'] = page;
      if (limit != null) qp['page_size'] = limit;
      if (status != null && status.isNotEmpty) qp['status'] = status;

      final response = await _apiClient.get(
        ApiConstants.customerOrders,
        queryParameters: qp.isNotEmpty ? qp : null,
      );
      final data = response.data;
      List<dynamic> items;
      if (data is Map<String, dynamic>) {
        items = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }
      final serverOrders = items
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();

      final localMatches = (status != null && status.isNotEmpty)
          ? _localCreatedOrders.where((o) => o.status == status).toList()
          : _localCreatedOrders;

      final existingIds = serverOrders.map((o) => o.id).toSet();
      return [
        ...localMatches.where((o) => !existingIds.contains(o.id)),
        ...serverOrders,
      ];
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
      final combined = [
        ..._localCreatedOrders,
        ..._mockOrders,
      ];
      if (status != null && status.isNotEmpty) {
        return combined.where((o) => o.status == status).toList();
      }
      return combined;
    }
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final localMatch = _localCreatedOrders.where((o) => o.id == id);
    if (localMatch.isNotEmpty) {
      return localMatch.first;
    }
    if (id.startsWith('ORD-')) {
      return _mockOrders.firstWhere(
        (o) => o.id == id,
        orElse: () => _mockOrders.first,
      );
    }

    try {
      final response =
          await _apiClient.get(ApiConstants.customerOrderDetail(id));
      final data = response.data;
      final d = data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return OrderModel.fromJson(d);
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockOrders.firstWhere(
        (o) => o.id == id,
        orElse: () => _mockOrders.first,
      );
    }
  }

  @override
  Future<List<OrderModel>> createOrder({
    required String cartId,
    required String shippingAddressId,
    String? idempotencyKey,
    List<OrderItemModel>? fallbackItems,
    double? fallbackTotal,
    String? fallbackStoreName,
  }) async {
    final effectiveIdempotencyKey =
        (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
            ? idempotencyKey.trim()
            : 'checkout-${DateTime.now().microsecondsSinceEpoch}';

    final request = CreateOrderRequestModel(
      cartId: cartId,
      shippingAddressId: shippingAddressId,
      idempotencyKey: effectiveIdempotencyKey,
    );

    try {
      final response = await _apiClient.post(
        ApiConstants.customerOrders,
        data: request.toJson(),
      );

      final data = response.data;
      List<dynamic> items;
      if (data is Map<String, dynamic> && data['data'] is List) {
        items = data['data'] as List<dynamic>;
      } else if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic> && data['data'] is Map) {
        items = [data['data']];
      } else {
        items = [];
      }
      final orders = items
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
      if (orders.isNotEmpty) {
        _mockOrders.insertAll(0, orders);
      }
      return orders;
    } on UnauthorizedException {
      rethrow;
    } on ServerException catch (e) {
      // Surface 409 INSUFFICIENT_STOCK errors directly per order_process.md Inventory flow
      if (e.statusCode == 409) {
        rethrow;
      }
      return _createLocalFallbackOrder(
        fallbackItems: fallbackItems,
        fallbackTotal: fallbackTotal,
        fallbackStoreName: fallbackStoreName,
      );
    } catch (_) {
      return _createLocalFallbackOrder(
        fallbackItems: fallbackItems,
        fallbackTotal: fallbackTotal,
        fallbackStoreName: fallbackStoreName,
      );
    }
  }

  List<OrderModel> _createLocalFallbackOrder({
    List<OrderItemModel>? fallbackItems,
    double? fallbackTotal,
    String? fallbackStoreName,
  }) {
    final now = DateTime.now();
    final orderId = 'ORD-${now.millisecondsSinceEpoch}';
    final orderNumber =
        'ORD-${now.millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    final total = fallbackTotal ?? 150.0;
    final storeName = fallbackStoreName ?? 'SETEC Official Store';
    final fallbackOrder = OrderModel(
      id: orderId,
      orderNumber: orderNumber,
      customerName: storeName,
      storeName: storeName,
      subtotalAmount: total,
      totalAmount: total,
      status: OrderStatus.pending,
      createdAt: now,
      itemCount: fallbackItems?.length ?? 1,
      items: fallbackItems ?? const [],
      statusHistory: [
        OrderStatusHistoryModel(
          id: 'sh-${now.millisecondsSinceEpoch}',
          fromStatus: null,
          toStatus: OrderStatus.pending,
          note: 'Order placed via cart checkout',
          createdAt: now,
        ),
      ],
    );
    _localCreatedOrders.insert(0, fallbackOrder);
    _mockOrders.insert(0, fallbackOrder);
    return [fallbackOrder];
  }

  @override
  Future<OrderPaymentBatchModel> payOrders({
    required List<String> orderIds,
    String? idempotencyKey,
    String? simulateOutcome,
    String? failureReason,
  }) async {
    final effectiveKey =
        (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
            ? idempotencyKey.trim()
            : 'pay-${DateTime.now().microsecondsSinceEpoch}';

    final uniqueIds = orderIds.toSet().where((id) => id.isNotEmpty).toList();
    final serverIds =
        uniqueIds.where((id) => !id.startsWith('ORD-')).toList();

    if (serverIds.isNotEmpty) {
      try {
        final request = OrderPaymentRequestModel(
          idempotencyKey: effectiveKey,
          orderIds: serverIds,
          simulateOutcome: simulateOutcome,
          failureReason: failureReason,
        );
        final response = await _apiClient.post(
          ApiConstants.customerOrdersPayment,
          data: request.toJson(),
        );
        final data = response.data;
        final d = data is Map<String, dynamic> &&
                data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : <String, dynamic>{});
        return OrderPaymentBatchModel.fromJson(d);
      } on NotFoundException {
        // Compatibility fallback to single-order endpoint per order_process.md Step 8
        if (serverIds.length == 1) {
          final response = await _apiClient.post(
            ApiConstants.customerOrderPayment(serverIds.first),
            data: {
              'idempotency_key': effectiveKey,
              'simulate_outcome': ?simulateOutcome,
              'failure_reason': ?failureReason,
            },
          );
          final data = response.data;
          final d = data is Map<String, dynamic> &&
                  data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : (data is Map<String, dynamic> ? data : <String, dynamic>{});
          return OrderPaymentBatchModel.fromJson(d);
        }
        rethrow;
      } on UnauthorizedException {
        rethrow;
      }
    }

    // Local mock order payment progression (pending -> confirmed or failed)
    final now = DateTime.now();
    final isFailed = simulateOutcome?.toLowerCase() == PaymentStatus.failed;
    final newOrderStatus =
        isFailed ? OrderStatus.failed : OrderStatus.confirmed;
    final newPaymentStatus =
        isFailed ? PaymentStatus.failed : PaymentStatus.succeeded;

    OrderModel updateOrderListItem(OrderModel existing) {
      final paymentRecord = OrderPaymentModel(
        id: 'pay-${now.millisecondsSinceEpoch}',
        orderId: existing.id,
        status: newPaymentStatus,
        amount: existing.totalAmount,
        currency: existing.currency,
        provider: 'internal_mock',
        paidAt: isFailed ? null : now,
        failureReason: failureReason,
      );
      final updatedHistory = <OrderStatusHistory>[
        ...?existing.statusHistory,
        OrderStatusHistoryModel(
          id: 'sh-${now.microsecondsSinceEpoch}',
          fromStatus: existing.status,
          toStatus: newOrderStatus,
          note: isFailed
              ? (failureReason ?? 'Payment failed')
              : 'Payment succeeded via internal payment service',
          createdAt: now,
        ),
      ];
      return OrderModel(
        id: existing.id,
        orderNumber: existing.orderNumber,
        customerId: existing.customerId,
        customerName: existing.customerName,
        storeId: existing.storeId,
        storeName: existing.storeName,
        shippingAddressId: existing.shippingAddressId,
        subtotalAmount: existing.subtotalAmount,
        shippingAmount: existing.shippingAmount,
        discountAmount: existing.discountAmount,
        taxAmount: existing.taxAmount,
        totalAmount: existing.totalAmount,
        currency: existing.currency,
        status: newOrderStatus,
        notes: existing.notes,
        itemCount: existing.itemCount,
        items: existing.items,
        payment: paymentRecord,
        shipments: existing.shipments,
        statusHistory: updatedHistory,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }

    for (var i = 0; i < _localCreatedOrders.length; i++) {
      if (uniqueIds.contains(_localCreatedOrders[i].id)) {
        _localCreatedOrders[i] = updateOrderListItem(_localCreatedOrders[i]);
      }
    }
    for (var i = 0; i < _mockOrders.length; i++) {
      if (uniqueIds.contains(_mockOrders[i].id)) {
        _mockOrders[i] = updateOrderListItem(_mockOrders[i]);
      }
    }

    return OrderPaymentBatchModel(
      id: 'batch-${DateTime.now().millisecondsSinceEpoch}',
      idempotencyKey: effectiveKey,
      status: newPaymentStatus,
      totalAmount: 0.0,
      paidAt: isFailed ? null : DateTime.now(),
      failureReason: failureReason,
    );
  }

  @override
  Future<OrderPaymentModel> getOrderPayment(String orderId) async {
    final response =
        await _apiClient.get(ApiConstants.customerOrderPayment(orderId));
    final data = response.data;
    final d =
        data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
    return OrderPaymentModel.fromJson(d);
  }

  @override
  Future<OrderModel> cancelOrder(String id) async {
    if (id.startsWith('ORD-')) {
      final now = DateTime.now();
      OrderModel buildCancelled(OrderModel old) {
        final updatedHistory = <OrderStatusHistory>[
          ...?old.statusHistory,
          OrderStatusHistoryModel(
            id: 'sh-${now.microsecondsSinceEpoch}',
            fromStatus: old.status,
            toStatus: OrderStatus.cancelled,
            note: 'Cancelled by customer',
            createdAt: now,
          ),
        ];
        return OrderModel(
          id: old.id,
          orderNumber: old.orderNumber,
          customerId: old.customerId,
          customerName: old.customerName,
          storeId: old.storeId,
          storeName: old.storeName,
          shippingAddressId: old.shippingAddressId,
          subtotalAmount: old.subtotalAmount,
          shippingAmount: old.shippingAmount,
          discountAmount: old.discountAmount,
          taxAmount: old.taxAmount,
          totalAmount: old.totalAmount,
          currency: old.currency,
          status: OrderStatus.cancelled,
          notes: old.notes,
          itemCount: old.itemCount,
          items: old.items,
          payment: old.payment,
          shipments: old.shipments,
          statusHistory: updatedHistory,
          createdAt: old.createdAt,
          updatedAt: now,
          cancelledAt: now,
        );
      }

      final localIdx = _localCreatedOrders.indexWhere((o) => o.id == id);
      if (localIdx >= 0) {
        _localCreatedOrders[localIdx] =
            buildCancelled(_localCreatedOrders[localIdx]);
      }
      final index = _mockOrders.indexWhere((o) => o.id == id);
      if (index >= 0) {
        final updated = buildCancelled(_mockOrders[index]);
        _mockOrders[index] = updated;
        return updated;
      }
      if (localIdx >= 0) {
        return _localCreatedOrders[localIdx];
      }
    }

    final response =
        await _apiClient.post(ApiConstants.customerOrderCancel(id));
    final data = response.data;
    final d =
        data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
    return OrderModel.fromJson(d);
  }

  @override
  Future<List<OrderStatusHistoryModel>> getOrderStatusHistory(
    String orderId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerOrderStatusHistory(orderId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      return list
          .whereType<Map<String, dynamic>>()
          .map(OrderStatusHistoryModel.fromJson)
          .toList();
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<OrderShipmentModel>> getOrderShipments(String orderId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerOrderShipments(orderId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is Map<String, dynamic> && data['data'] is Map
              ? [data['data']]
              : (data is List ? data : <dynamic>[]));
      return list
          .whereType<Map<String, dynamic>>()
          .map(OrderShipmentModel.fromJson)
          .toList();
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<OrderShipmentModel> getShipment(String shipmentId) async {
    final response = await _apiClient.get(
      ApiConstants.customerShipmentDetail(shipmentId),
    );
    final data = response.data;
    final d =
        data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
    return OrderShipmentModel.fromJson(d);
  }

  @override
  Future<List<ShipmentEventModel>> getShipmentEvents(String shipmentId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.customerShipmentEvents(shipmentId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ShipmentEventModel.fromJson)
          .toList();
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<OrderShipmentModel> confirmDelivery(
    String shipmentId, {
    String? note,
  }) async {
    final request = ConfirmDeliveryRequestModel(
      note: note ?? 'Product received in good condition',
    );
    try {
      final response = await _apiClient.post(
        ApiConstants.customerShipmentConfirmDelivery(shipmentId),
        data: request.toJson(),
      );
      final data = response.data;
      final d =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
      return OrderShipmentModel.fromJson(d);
    } on NotFoundException {
      final response = await _apiClient.post(
        ApiConstants.customerShipmentConfirmDeliverySlash(shipmentId),
        data: request.toJson(),
      );
      final data = response.data;
      final d =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
      return OrderShipmentModel.fromJson(d);
    }
  }
}
