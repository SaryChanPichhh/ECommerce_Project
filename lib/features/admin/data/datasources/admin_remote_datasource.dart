import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_models.dart';

class AdminRemoteDataSource {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AdminRemoteDataSource({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  }) : _apiClient = apiClient,
       _localStorage = localStorage {
    _ensureSeedData();
  }

  // ──────────────────────────────────────────────────────────
  // Synchronized In-Memory Seed Store (Matches lib/docs/img.png & Guide)
  // ──────────────────────────────────────────────────────────
  static bool _seeded = false;
  static final List<OrderModel> _orders = [];
  static final List<OrderShipmentModel> _shipments = [];
  static final List<AdminProduct> _products = [];
  static final List<AdminCategory> _categories = [];
  static final List<AdminStore> _stores = [];
  static final List<AdminTag> _tags = [];
  static final List<AdminUserCustomer> _users = [];
  static final List<AdminReview> _reviews = [];
  static final List<AdminSupportTicket> _tickets = [];
  static final List<AdminBroadcastNotification> _notifications = [];
  static final List<AdminLegalDocument> _legalDocs = [];
  static final List<AdminConversation> _conversations = [];
  static final List<AdminDeviceSession> _sessions = [];

  static void registerExternalProduct(AdminProduct product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
    } else {
      _products.insert(0, product);
    }
  }

  void _ensureSeedData() {
    if (_seeded) return;
    _seeded = true;

    final oct24 = DateTime(2026, 10, 24, 10, 20);
    final nov01 = DateTime.now().subtract(const Duration(minutes: 12));

    if (_orders.isEmpty) {
      _orders.addAll([
        OrderModel(
          id: 'ord-20261101-0002',
          orderNumber: 'ord-20261101-0002',
          customerId: 'usr-cust-002',
          customerName: 'Chanthy Mey',
          customerPhone: '+855 12 889 442',
          customerEmail: 'chanthy.mey@setec.edu.kh',
          storeId: 'str-000005',
          storeName: 'Kutuku Official',
          shippingAddressId: 'adr-000002',
          shippingAddressText:
              'St. 271, Sangkat Phsar Doeum Thkov, Chamkarmon, Phnom Penh, Cambodia',
          subtotalAmount: 65.00,
          shippingAmount: 0.00,
          discountAmount: 0.00,
          taxAmount: 0.00,
          totalAmount: 65.00,
          currency: 'USD',
          status: OrderStatus.pending,
          notes: 'Order placed via cart checkout — awaiting admin approval',
          itemCount: 2,
          items: const [
            OrderItemModel(
              id: 'item-201',
              productId: 'prd-000001',
              productVariantId: 'var-000001',
              productName: 'Classic Cotton T-Shirt',
              variantName: 'Black / M',
              sku: 'TSHIRT-BLK-M',
              quantity: 1,
              unitPrice: 25.00,
              totalPrice: 25.00,
            ),
            OrderItemModel(
              id: 'item-202',
              productId: 'prd-000002',
              productVariantId: 'var-000002',
              productName: 'Urban Cargo Jogger',
              variantName: 'Olive / L',
              sku: 'JOGGER-OLV-L',
              quantity: 1,
              unitPrice: 40.00,
              totalPrice: 40.00,
            ),
          ],
          payment: OrderPaymentModel(
            id: 'pay-20261101-0002',
            orderId: 'ord-20261101-0002',
            batchId: 'batch-20261101-0002',
            status: PaymentStatus.pending,
            amount: 65.00,
            currency: 'USD',
            provider: 'internal_payment',
            providerReference: 'REF-PENDING-0002',
          ),
          shipments: const [],
          statusHistory: [
            OrderStatusHistoryModel(
              id: 'sh-init-0002',
              fromStatus: null,
              toStatus: OrderStatus.pending,
              note: 'Order placed via cart checkout',
              createdAt: nov01,
            ),
          ],
          createdAt: nov01,
          updatedAt: nov01,
        ),
        OrderModel(
          id: 'ord-20261024-0001',
          orderNumber: 'ord-20261024-0001',
          customerId: 'usr-cust-001',
          customerName: 'Sok Dara',
          customerPhone: '+855 96 123 4567',
          customerEmail: 'sok.dara@example.com',
          storeId: 'str-000005',
          storeName: 'Kutuku Official',
          shippingAddressId: 'adr-000001',
          shippingAddressText:
              'No. 168 Russian Federation Blvd (110), Toul Kork, Phnom Penh, Cambodia',
          subtotalAmount: 45.00,
          shippingAmount: 0.00,
          discountAmount: 0.00,
          taxAmount: 0.00,
          totalAmount: 45.00,
          currency: 'USD',
          status: OrderStatus.confirmed,
          notes: 'Payment succeeded via internal payment service',
          itemCount: 2,
          items: const [
            OrderItemModel(
              id: 'item-101',
              productId: 'prd-000001',
              productVariantId: 'var-000001',
              productName: 'Classic Cotton T-Shirt',
              variantName: 'Black / M',
              sku: 'TSHIRT-BLK-M',
              quantity: 1,
              unitPrice: 20.00,
              totalPrice: 20.00,
            ),
            OrderItemModel(
              id: 'item-102',
              productId: 'prd-000002',
              productVariantId: 'var-000002',
              productName: 'Classic Cotton T-Shirt',
              variantName: 'White / L',
              sku: 'TSHIRT-WHT-L',
              quantity: 1,
              unitPrice: 25.00,
              totalPrice: 25.00,
            ),
          ],
          payment: OrderPaymentModel(
            id: 'pay-20261024-0001',
            orderId: 'ord-20261024-0001',
            batchId: 'batch-20261024-0001',
            status: PaymentStatus.succeeded,
            amount: 45.00,
            currency: 'USD',
            provider: 'internal_payment',
            providerReference: 'REF-20261024-0001',
            paidAt: oct24,
          ),
          shipments: const [],
          statusHistory: [
            OrderStatusHistoryModel(
              id: 'sh-init-0001',
              fromStatus: null,
              toStatus: OrderStatus.pending,
              note: 'Order placed via cart checkout',
              createdAt: oct24.subtract(const Duration(minutes: 5)),
            ),
            OrderStatusHistoryModel(
              id: 'sh-conf-0001',
              fromStatus: OrderStatus.pending,
              toStatus: OrderStatus.confirmed,
              note: 'Payment succeeded via internal payment service',
              createdAt: oct24,
            ),
          ],
          createdAt: oct24,
          updatedAt: oct24,
        ),
      ]);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 1. Admin Auth & Session Management (Sections 4, 8.1 & 8.2)
  // ──────────────────────────────────────────────────────────
  Future<bool> loginAsAdmin({
    String email = 'admin@example.com',
    String password = 'AdminSecret123!',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final body = response.data;
      final payload =
          body is Map<String, dynamic> && body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : (body is Map<String, dynamic> ? body : <String, dynamic>{});
      final token = payload['access_token']?.toString() ?? '';
      final refreshToken = payload['refresh_token']?.toString() ?? '';
      if (token.isNotEmpty) {
        await _localStorage.saveAccessToken(token);
        if (refreshToken.isNotEmpty) {
          await _localStorage.saveRefreshToken(refreshToken);
        }
        final user = UserModel(
          id: payload['user_id']?.toString() ?? 'admin-uuid-001',
          name: email == 'admin@example.com'
              ? 'SETEC System Admin'
              : email.split('@').first,
          email: email,
          role: payload['role']?.toString() ?? 'admin',
          status: 'active',
        );
        await _localStorage.saveUserData(user.toJson());
        UserSession.instance.setSession(token: token, user: user);
        return true;
      }
    } catch (_) {
      // Fallback local admin session when server is offline
      const fallbackToken = 'local-admin-jwt-session-token';
      const user = UserModel(
        id: 'admin-uuid-001',
        name: 'SETEC System Admin',
        email: 'admin@example.com',
        role: 'admin',
        status: 'active',
      );
      await _localStorage.saveAccessToken(fallbackToken);
      await _localStorage.saveUserData(user.toJson());
      UserSession.instance.setSession(token: fallbackToken, user: user);
      return true;
    }
    return false;
  }

  /// Section 8.1: `POST /api/v1/auth/refresh/`
  Future<bool> refreshAdminToken() async {
    try {
      final refreshToken = _localStorage.getRefreshToken();
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken ?? 'local-admin-refresh-token'},
      );
      final body = response.data;
      final payload =
          body is Map<String, dynamic> && body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : (body is Map<String, dynamic> ? body : <String, dynamic>{});
      final newAccess = payload['access_token']?.toString() ?? '';
      final newRefresh = payload['refresh_token']?.toString() ?? '';
      if (newAccess.isNotEmpty) {
        await _localStorage.saveAccessToken(newAccess);
        if (newRefresh.isNotEmpty) {
          await _localStorage.saveRefreshToken(newRefresh);
        }
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Section 8.1: `POST /api/v1/auth/logout/`
  Future<void> logoutAdmin() async {
    try {
      final refreshToken = _localStorage.getRefreshToken();
      await _apiClient.post(
        ApiConstants.logout,
        data: {
          if (refreshToken != null && refreshToken.isNotEmpty)
            'refresh_token': refreshToken,
        },
      );
    } catch (_) {
      // Ignore network/token errors during logout
    } finally {
      UserSession.instance.clear();
      await _localStorage.clearAuthData();
    }
  }

  /// Section 8.1 & 8.2: `GET /api/v1/auth/me/` & `GET /api/v1/users/me/`
  Future<UserModel> getAdminAuthMe() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return UserModel.fromJson(map);
      }
    } catch (_) {}
    final current = UserSession.instance.currentUser;
    if (current != null) {
      return UserModel(
        id: current.id,
        name: current.name,
        email: current.email,
        phone: current.phone,
        avatar: current.avatar,
        role: current.role,
        status: current.status,
      );
    }
    return const UserModel(
      id: 'admin-uuid-001',
      name: 'SETEC System Admin',
      email: 'admin@example.com',
      phone: '+855 12 000 001',
      role: 'admin',
      status: 'active',
    );
  }

  /// Section 8.2: `PATCH /api/v1/users/me/`
  Future<UserModel> updateAdminProfileMe({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final current = await getAdminAuthMe();
    final updatedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : current.name;
    final parts = updatedName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    try {
      await _apiClient.patch(
        ApiConstants.userMe,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': ?phone,
          'avatar_url': ?avatarUrl,
        },
      );
    } catch (_) {}

    final updated = UserModel(
      id: current.id,
      name: updatedName,
      email: current.email,
      phone: phone ?? current.phone,
      avatar: avatarUrl ?? current.avatar,
      role: current.role,
      status: current.status,
    );
    await _localStorage.saveUserData(updated.toJson());
    final token =
        _localStorage.getAccessToken() ?? 'local-admin-jwt-session-token';
    UserSession.instance.setSession(token: token, user: updated);
    return updated;
  }

  /// Section 8.2: `GET /api/v1/users/me/sessions/`
  Future<List<AdminDeviceSession>> getAdminDeviceSessions() async {
    try {
      final response = await _apiClient.get(ApiConstants.userSessions);
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminDeviceSession.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    return List<AdminDeviceSession>.from(_sessions);
  }

  /// Section 8.2: `DELETE /api/v1/users/me/sessions/{id}/` (or `/revoke/`)
  Future<void> revokeAdminDeviceSession(String sessionId) async {
    try {
      await _apiClient.delete(ApiConstants.userSessionRevoke(sessionId));
    } catch (_) {
      try {
        await _apiClient.delete(ApiConstants.userSessionRevokeAlias(sessionId));
      } catch (_) {}
    }
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  // ──────────────────────────────────────────────────────────
  // 2. Admin Orders & Fulfillment (Section 9.5 & order_process.md Steps 1-11)
  // ──────────────────────────────────────────────────────────
  Future<List<OrderModel>> getAdminOrders({
    String? status,
    String? userId,
    String? storeId,
    int? page,
    int? pageSize,
  }) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      qp['status'] = status;
    }
    if (userId != null && userId.isNotEmpty) {
      qp['user_id'] = userId;
    }
    if (storeId != null && storeId.isNotEmpty) {
      qp['store_id'] = storeId;
    }
    if (page != null) qp['page'] = page;
    if (pageSize != null) qp['page_size'] = pageSize;

    final fetchedRemote = <OrderModel>[];

    // 1. Fetch from Admin Orders endpoint (/api/v1/admin/orders/)
    try {
      final response = await _apiClient.get(
        ApiConstants.adminOrders,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      fetchedRemote.addAll(
        rawList.whereType<Map<String, dynamic>>().map(OrderModel.fromJson),
      );
    } catch (_) {}

    // 2. Also check Customer Orders endpoint (/api/v1/customer/orders/) so any
    // customer order placed from the app/backend is immediately synced.
    try {
      final custResp = await _apiClient.get(ApiConstants.customerOrders);
      final custData = custResp.data;
      final custList =
          custData is Map<String, dynamic> && custData['data'] is List
          ? custData['data'] as List<dynamic>
          : (custData is List ? custData : <dynamic>[]);
      for (final raw in custList.whereType<Map<String, dynamic>>()) {
        final parsed = OrderModel.fromJson(raw);
        if (!fetchedRemote.any(
          (o) => o.id == parsed.id || o.orderNumber == parsed.id,
        )) {
          fetchedRemote.add(parsed);
        }
      }
    } catch (_) {}

    // 3. Synchronize remote orders into `_orders` while preserving local
    // enriched fields (items, payment, shipments, statusHistory) and recent transitions.
    for (final remote in fetchedRemote) {
      _mergeOrderIntoLocalStore(remote);
    }

    return _filterLocalOrders(
      _orders,
      status: status,
      userId: userId,
      storeId: storeId,
    );
  }

  void _mergeOrderIntoLocalStore(OrderModel incoming) {
    if (incoming.id.isEmpty) return;
    final idx = _orders.indexWhere(
      (o) =>
          o.id == incoming.id ||
          (incoming.orderNumber != null &&
              incoming.orderNumber!.isNotEmpty &&
              o.orderNumber == incoming.orderNumber),
    );
    final linkedShipments = _shipments
        .where((s) => s.orderId == incoming.id || s.orderId == incoming.orderNumber)
        .toList();

    if (idx == -1) {
      final enriched = OrderModel(
        id: incoming.id,
        orderNumber: incoming.orderNumber ?? incoming.id,
        customerId: incoming.customerId ?? 'usr-cust-remote',
        customerName: (incoming.customerName != null &&
                incoming.customerName!.trim().isNotEmpty)
            ? incoming.customerName
            : 'Customer',
        customerPhone: incoming.customerPhone ?? '+855 12 345 678',
        customerEmail: incoming.customerEmail ?? 'customer@setec.edu.kh',
        storeId: incoming.storeId ?? 'str-000005',
        storeName: incoming.storeName ?? 'Kutuku Official',
        shippingAddressId: incoming.shippingAddressId ?? 'adr-000001',
        shippingAddressText: incoming.shippingAddressText ??
            'No. 168 Russian Federation Blvd (110), Toul Kork, Phnom Penh',
        subtotalAmount: incoming.subtotalAmount > 0
            ? incoming.subtotalAmount
            : incoming.totalAmount,
        shippingAmount: incoming.shippingAmount,
        discountAmount: incoming.discountAmount,
        taxAmount: incoming.taxAmount,
        totalAmount: incoming.totalAmount,
        currency: incoming.currency,
        status: incoming.status,
        notes: incoming.notes ?? 'Synced from backend order service',
        itemCount: incoming.itemCount ?? incoming.items?.length ?? 1,
        items: (incoming.items != null && incoming.items!.isNotEmpty)
            ? incoming.items
            : [
                OrderItemModel(
                  id: 'itm-${incoming.id}',
                  productId: _products.isNotEmpty
                      ? _products.first.id
                      : 'prd-000001',
                  productVariantId: (_products.isNotEmpty &&
                          _products.first.variants.isNotEmpty)
                      ? _products.first.variants.first.id
                      : 'var-000001',
                  productName: _products.isNotEmpty
                      ? _products.first.name
                      : 'Classic Cotton T-Shirt',
                  variantName: (_products.isNotEmpty &&
                          _products.first.variants.isNotEmpty)
                      ? _products.first.variants.first.name
                      : 'Standard',
                  sku: _products.isNotEmpty
                      ? _products.first.sku
                      : 'TSHIRT-BLK-M',
                  quantity: incoming.itemCount ?? 1,
                  unitPrice: incoming.totalAmount,
                  totalPrice: incoming.totalAmount,
                ),
              ],
        payment: incoming.payment ??
            OrderPaymentModel(
              id: 'pay-${incoming.id}',
              orderId: incoming.id,
              status: incoming.status == OrderStatus.pending
                  ? PaymentStatus.pending
                  : PaymentStatus.succeeded,
              amount: incoming.totalAmount,
              currency: incoming.currency,
              provider: 'internal_payment',
              paidAt: incoming.status == OrderStatus.pending
                  ? null
                  : (incoming.createdAt ?? DateTime.now()),
            ),
        shipments: (incoming.shipments != null && incoming.shipments!.isNotEmpty)
            ? incoming.shipments
            : linkedShipments,
        statusHistory: (incoming.statusHistory != null &&
                incoming.statusHistory!.isNotEmpty)
            ? incoming.statusHistory
            : [
                OrderStatusHistoryModel(
                  id: 'sh-init-${incoming.id}',
                  fromStatus: null,
                  toStatus: incoming.status,
                  note: 'Order placed via cart checkout',
                  createdAt: incoming.createdAt ?? DateTime.now(),
                ),
              ],
        createdAt: incoming.createdAt ?? DateTime.now(),
        updatedAt: incoming.updatedAt ?? incoming.createdAt ?? DateTime.now(),
        cancelledAt: incoming.cancelledAt,
      );
      _orders.insert(0, enriched);
    } else {
      final existing = _orders[idx];
      // Preserve local status if local was updated more recently than remote
      final keepLocalStatus = existing.updatedAt != null &&
          (incoming.updatedAt == null ||
              existing.updatedAt!.isAfter(incoming.updatedAt!));
      final effectiveStatus =
          keepLocalStatus ? existing.status : incoming.status;

      _orders[idx] = OrderModel(
        id: existing.id,
        orderNumber: incoming.orderNumber ?? existing.orderNumber,
        customerId: incoming.customerId ?? existing.customerId,
        customerName: incoming.customerName ?? existing.customerName,
        customerPhone: incoming.customerPhone ?? existing.customerPhone,
        customerEmail: incoming.customerEmail ?? existing.customerEmail,
        storeId: incoming.storeId ?? existing.storeId,
        storeName: incoming.storeName ?? existing.storeName,
        shippingAddressId:
            incoming.shippingAddressId ?? existing.shippingAddressId,
        shippingAddressText:
            incoming.shippingAddressText ?? existing.shippingAddressText,
        subtotalAmount: incoming.subtotalAmount > 0
            ? incoming.subtotalAmount
            : existing.subtotalAmount,
        shippingAmount: incoming.shippingAmount > 0
            ? incoming.shippingAmount
            : existing.shippingAmount,
        discountAmount: incoming.discountAmount > 0
            ? incoming.discountAmount
            : existing.discountAmount,
        taxAmount:
            incoming.taxAmount > 0 ? incoming.taxAmount : existing.taxAmount,
        totalAmount: incoming.totalAmount > 0
            ? incoming.totalAmount
            : existing.totalAmount,
        currency: incoming.currency,
        status: effectiveStatus,
        notes: keepLocalStatus
            ? existing.notes
            : (incoming.notes ?? existing.notes),
        itemCount: incoming.itemCount ?? existing.itemCount,
        items: (incoming.items != null && incoming.items!.isNotEmpty)
            ? incoming.items
            : existing.items,
        payment: incoming.payment ?? existing.payment,
        shipments: linkedShipments.isNotEmpty
            ? linkedShipments
            : ((incoming.shipments != null && incoming.shipments!.isNotEmpty)
                  ? incoming.shipments
                  : existing.shipments),
        statusHistory: (existing.statusHistory != null &&
                existing.statusHistory!.length >=
                    (incoming.statusHistory?.length ?? 0))
            ? existing.statusHistory
            : incoming.statusHistory,
        createdAt: incoming.createdAt ?? existing.createdAt,
        updatedAt: keepLocalStatus
            ? existing.updatedAt
            : (incoming.updatedAt ?? existing.updatedAt),
        cancelledAt: incoming.cancelledAt ?? existing.cancelledAt,
      );
    }
  }

  /// Steps 8 & 9 (+ optional Step 10) of `lib/docs/order_process.md`:
  /// Approves a customer's `pending` order by:
  /// 1. Completing/verifying payment (`POST /api/v1/customer/orders/payment/` & `/customer/orders/{id}/payment/`)
  /// 2. Confirming the order as Admin (`PATCH /api/v1/admin/orders/{id}/status/` -> `confirmed`)
  /// 3. Optionally starting store preparation (`PATCH /api/v1/admin/orders/{id}/processing` -> `processing`)
  Future<OrderModel> approveCustomerOrder(
    String orderId, {
    String? note,
    bool autoStartPreparing = false,
  }) async {
    final now = DateTime.now();
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Customer order approved & payment confirmed by Admin';

    // Step 8: Ensure payment is marked succeeded on backend if order was unpaid
    try {
      final paymentReq = OrderPaymentRequestModel(
        idempotencyKey: 'pay-approve-$orderId-${now.millisecondsSinceEpoch}',
        orderIds: [orderId],
        simulateOutcome: 'succeeded',
      );
      await _apiClient.post(
        ApiConstants.customerOrdersPayment,
        data: paymentReq.toJson(),
      );
    } catch (_) {
      try {
        await _apiClient.post(
          ApiConstants.customerOrderPayment(orderId),
          data: {
            'idempotency_key':
                'pay-single-$orderId-${now.millisecondsSinceEpoch}',
            'simulate_outcome': 'succeeded',
          },
        );
      } catch (_) {}
    }

    // Step 9: Admin confirms the order (`PATCH /api/v1/admin/orders/{order_id}/status/`)
    try {
      await _apiClient.patch(
        ApiConstants.adminOrderStatus(orderId),
        data: {
          'status': OrderStatus.confirmed,
          'note': effectiveNote,
        },
      );
    } catch (_) {}

    var updated = _applyLocalOrderTransition(
      orderId,
      toStatus: OrderStatus.confirmed,
      note: effectiveNote,
      timestamp: now,
    );

    // Optional Step 10: Immediately transition `confirmed` -> `processing`
    if (autoStartPreparing) {
      updated = await startOrderPreparing(
        orderId,
        note: 'Order approved and store started preparing the products',
      );
    }

    return updated;
  }

  /// Steps 1–8 of `lib/docs/order_process.md`:
  /// Places/simulates a customer order end-to-end (Cart -> Address -> Checkout Preview -> Place Order -> Stock Deduction -> Optional Payment)
  /// and synchronizes it into the Admin Order Approval Queue & Product Variant Stock!
  Future<OrderModel> placeCustomerOrderAndSync({
    String? productId,
    String? variantId,
    int quantity = 1,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? shippingAddressText,
    bool autoPayAndConfirm = false,
  }) async {
    final now = DateTime.now();

    // Pick product and variant from catalog
    final targetProduct = (productId != null && productId.isNotEmpty)
        ? _products.firstWhere(
            (p) => p.id == productId,
            orElse: () => _products.isNotEmpty
                ? _products.first
                : AdminProduct(
                    id: 'prd-000001',
                    storeId: 'str-000005',
                    storeName: 'Kutuku Official',
                    categoryId: 'cat-000001',
                    categoryName: 'Apparel',
                    name: 'Classic Cotton T-Shirt',
                    slug: 'classic-cotton-tshirt',
                    sku: 'TSHIRT-BLK-M',
                    description: 'Premium cotton crew-neck shirt',
                    basePrice: 25.0,
                    stockQuantity: 30,
                  ),
          )
        : (_products.isNotEmpty
              ? _products.first
              : AdminProduct(
                  id: 'prd-000001',
                  storeId: 'str-000005',
                  storeName: 'Kutuku Official',
                  categoryId: 'cat-000001',
                  categoryName: 'Apparel',
                  name: 'Classic Cotton T-Shirt',
                  slug: 'classic-cotton-tshirt',
                  sku: 'TSHIRT-BLK-M',
                  description: 'Premium cotton crew-neck shirt',
                  basePrice: 25.0,
                  stockQuantity: 30,
                ));

    final targetVariant = (variantId != null &&
            variantId.isNotEmpty &&
            targetProduct.variants.any((v) => v.id == variantId))
        ? targetProduct.variants.firstWhere((v) => v.id == variantId)
        : (targetProduct.variants.isNotEmpty
              ? targetProduct.variants.first
              : AdminProductVariant(
                  id: 'var-${targetProduct.id}-default',
                  productId: targetProduct.id,
                  sku: targetProduct.sku,
                  name: 'Standard',
                  price: targetProduct.basePrice,
                  stockQuantity: targetProduct.stockQuantity,
                ));

    String? remoteCartId;
    String? remoteAddressId;
    OrderModel? createdRemoteOrder;

    // Step 1 & 2: Add item to customer cart & select all (`POST /api/v1/customer/cart/items/`)
    try {
      await _apiClient.post(
        ApiConstants.customerCartItems,
        data: {
          'product_id': targetProduct.id,
          'product_variant_id': targetVariant.id,
          'quantity': quantity,
        },
      );
      await _apiClient.post(
        ApiConstants.customerCartSelectAll,
        data: {'is_selected': true},
      );
    } catch (_) {}

    // Step 3: Get customer cart (`GET /api/v1/customer/cart/`)
    try {
      final cartResp = await _apiClient.get(ApiConstants.customerCart);
      final cartData = cartResp.data;
      final cartMap =
          cartData is Map<String, dynamic> && cartData['data'] is Map<String, dynamic>
          ? cartData['data'] as Map<String, dynamic>
          : (cartData is Map<String, dynamic> ? cartData : null);
      remoteCartId = cartMap?['id']?.toString() ?? cartMap?['cart_id']?.toString();
    } catch (_) {}

    // Step 4: Get or create customer shipping address (`GET/POST /api/v1/customer/addresses/`)
    try {
      final addrResp = await _apiClient.get(ApiConstants.customerAddresses);
      final addrData = addrResp.data;
      final addrList = addrData is Map<String, dynamic> && addrData['data'] is List
          ? addrData['data'] as List<dynamic>
          : (addrData is List ? addrData : <dynamic>[]);
      if (addrList.isNotEmpty && addrList.first is Map) {
        remoteAddressId = (addrList.first as Map)['id']?.toString();
      } else {
        final createdAddr = await _apiClient.post(
          ApiConstants.customerAddresses,
          data: {
            'recipient_name': customerName ?? 'Sok Dara',
            'phone_number': customerPhone ?? '+855 96 123 4567',
            'street_line_1':
                shippingAddressText ??
                'No. 168 Russian Federation Blvd (110)',
            'district': 'Toul Kork',
            'city': 'Phnom Penh',
            'province': 'Phnom Penh',
            'country': 'Cambodia',
            'is_default': true,
          },
        );
        final cData = createdAddr.data;
        final cMap =
            cData is Map<String, dynamic> && cData['data'] is Map<String, dynamic>
            ? cData['data'] as Map<String, dynamic>
            : (cData is Map<String, dynamic> ? cData : null);
        remoteAddressId = cMap?['id']?.toString();
      }
    } catch (_) {}

    // Step 5 & 6: Checkout preview & Place order (`POST /api/v1/customer/orders/`)
    if (remoteAddressId != null && remoteAddressId.isNotEmpty) {
      try {
        await _apiClient.post(
          ApiConstants.customerCartCheckoutPreview,
          data: {'shipping_address_id': remoteAddressId},
        );
      } catch (_) {}

      if (remoteCartId != null && remoteCartId.isNotEmpty) {
        try {
          final orderReq = CreateOrderRequestModel(
            cartId: remoteCartId,
            shippingAddressId: remoteAddressId,
            idempotencyKey: 'checkout-${now.millisecondsSinceEpoch}',
          );
          final orderResp = await _apiClient.post(
            ApiConstants.customerOrders,
            data: orderReq.toJson(),
          );
          final oData = orderResp.data;
          final rawOrders =
              oData is Map<String, dynamic> && oData['data'] is Map && (oData['data'] as Map)['orders'] is List
              ? (oData['data'] as Map)['orders'] as List<dynamic>
              : (oData is Map<String, dynamic> && oData['orders'] is List
                    ? oData['orders'] as List<dynamic>
                    : <dynamic>[]);
          if (rawOrders.isNotEmpty && rawOrders.first is Map<String, dynamic>) {
            createdRemoteOrder = OrderModel.fromJson(
              rawOrders.first as Map<String, dynamic>,
            );
          } else if (oData is Map<String, dynamic> &&
              oData['data'] is Map<String, dynamic>) {
            createdRemoteOrder = OrderModel.fromJson(
              oData['data'] as Map<String, dynamic>,
            );
          }
        } catch (_) {}
      }
    }

    // Deduct stock quantity on the product variant per Step 6 of `order_process.md`
    _adjustVariantStockForProduct(
      productId: targetProduct.id,
      variantId: targetVariant.id,
      delta: -quantity,
    );

    final unitPrice = targetVariant.price > 0
        ? targetVariant.price
        : targetProduct.basePrice;
    final lineTotal = unitPrice * quantity;
    final seq = (_orders.length + 1).toString().padLeft(4, '0');
    final datePart =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final generatedId = createdRemoteOrder?.id.isNotEmpty == true
        ? createdRemoteOrder!.id
        : 'ord-$datePart-$seq';

    final initialStatus = autoPayAndConfirm
        ? OrderStatus.confirmed
        : OrderStatus.pending;

    final newOrder = OrderModel(
      id: generatedId,
      orderNumber: createdRemoteOrder?.orderNumber ?? generatedId,
      customerId: createdRemoteOrder?.customerId ?? 'usr-cust-live',
      customerName: (customerName != null && customerName.trim().isNotEmpty)
          ? customerName.trim()
          : (createdRemoteOrder?.customerName ?? 'Sok Dara'),
      customerPhone: (customerPhone != null && customerPhone.trim().isNotEmpty)
          ? customerPhone.trim()
          : (createdRemoteOrder?.customerPhone ?? '+855 96 123 4567'),
      customerEmail: (customerEmail != null && customerEmail.trim().isNotEmpty)
          ? customerEmail.trim()
          : (createdRemoteOrder?.customerEmail ?? 'sok.dara@example.com'),
      storeId: targetProduct.storeId,
      storeName: targetProduct.storeName,
      shippingAddressId: remoteAddressId ?? 'adr-000001',
      shippingAddressText:
          (shippingAddressText != null && shippingAddressText.trim().isNotEmpty)
          ? shippingAddressText.trim()
          : 'No. 168 Russian Federation Blvd (110), Toul Kork, Phnom Penh, Cambodia',
      subtotalAmount: lineTotal,
      shippingAmount: 0.0,
      discountAmount: 0.0,
      taxAmount: 0.0,
      totalAmount: lineTotal,
      currency: 'USD',
      status: initialStatus,
      notes: autoPayAndConfirm
          ? 'Payment succeeded via internal payment service'
          : 'Order placed via cart checkout — awaiting admin approval',
      itemCount: quantity,
      items: [
        OrderItemModel(
          id: 'itm-${now.millisecondsSinceEpoch}',
          productId: targetProduct.id,
          productVariantId: targetVariant.id,
          productName: targetProduct.name,
          variantName: targetVariant.name,
          sku: targetVariant.sku.isNotEmpty
              ? targetVariant.sku
              : targetProduct.sku,
          productImageUrl: targetProduct.imageUrl,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: lineTotal,
        ),
      ],
      payment: OrderPaymentModel(
        id: 'pay-${now.millisecondsSinceEpoch}',
        orderId: generatedId,
        batchId: 'batch-${now.millisecondsSinceEpoch}',
        status: autoPayAndConfirm
            ? PaymentStatus.succeeded
            : PaymentStatus.pending,
        amount: lineTotal,
        currency: 'USD',
        provider: 'internal_payment',
        providerReference: 'REF-$seq',
        paidAt: autoPayAndConfirm ? now : null,
      ),
      shipments: const [],
      statusHistory: [
        OrderStatusHistoryModel(
          id: 'sh-placed-${now.microsecondsSinceEpoch}',
          fromStatus: null,
          toStatus: OrderStatus.pending,
          note: 'Order placed via cart checkout',
          createdAt: now,
        ),
        if (autoPayAndConfirm)
          OrderStatusHistoryModel(
            id: 'sh-paid-${now.microsecondsSinceEpoch + 1}',
            fromStatus: OrderStatus.pending,
            toStatus: OrderStatus.confirmed,
            note: 'Payment succeeded via internal payment service',
            createdAt: now,
          ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _orders.removeWhere((o) => o.id == newOrder.id);
    _orders.insert(0, newOrder);

    if (autoPayAndConfirm && createdRemoteOrder != null) {
      await approveCustomerOrder(newOrder.id);
    }

    return newOrder;
  }

  /// Adjusts `ProductVariant.stock_quantity` and `Product.stockQuantity` when an order
  /// is placed (`delta < 0`, Step 6) or cancelled/failed (`delta > 0`, Stock Restoration).
  void _adjustVariantStockForProduct({
    required String productId,
    String? variantId,
    String? sku,
    required int delta,
  }) {
    final pIdx = _products.indexWhere(
      (p) => p.id == productId || (sku != null && p.sku == sku),
    );
    if (pIdx == -1) return;

    final prod = _products[pIdx];
    final updatedVariants = prod.variants.map((v) {
      final matchesVariant = (variantId != null && v.id == variantId) ||
          (sku != null && v.sku == sku) ||
          prod.variants.length == 1;
      if (!matchesVariant) return v;

      final nextStock = (v.stockQuantity + delta).clamp(0, 999999);
      String nextStatus = v.status;
      if (nextStock == 0) {
        nextStatus = 'out_of_stock';
      } else if (v.status == 'out_of_stock' && nextStock > 0) {
        nextStatus = 'active';
      }
      return v.copyWith(stockQuantity: nextStock, status: nextStatus);
    }).toList();

    final nextProdStock = (prod.stockQuantity + delta).clamp(0, 999999);
    _products[pIdx] = prod.copyWith(
      stockQuantity: nextProdStock,
      variants: updatedVariants,
    );
  }

  List<OrderModel> _filterLocalOrders(
    List<OrderModel> source, {
    String? status,
    String? userId,
    String? storeId,
  }) {
    return source.where((o) {
      if (status != null &&
          status.isNotEmpty &&
          status != 'all' &&
          o.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }
      if (userId != null && userId.isNotEmpty && o.customerId != userId) {
        return false;
      }
      if (storeId != null && storeId.isNotEmpty && o.storeId != storeId) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<OrderModel> getAdminOrderDetail(String orderId) async {
    final localIdx = _orders.indexWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
    );
    try {
      final response = await _apiClient.get(
        ApiConstants.adminOrderDetail(orderId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      final parsed = OrderModel.fromJson(map);
      if (localIdx != -1) {
        _orders[localIdx] = parsed;
      }
      return parsed;
    } catch (_) {
      if (localIdx != -1) return _orders[localIdx];
      return _orders.first;
    }
  }

  /// Step 9 Manual / Admin Order Status Update (`PATCH /api/v1/admin/orders/{order_id}/status/`)
  Future<OrderModel> updateAdminOrderStatus(
    String orderId, {
    required String status,
    String? note,
  }) async {
    final now = DateTime.now();
    try {
      await _apiClient.patch(
        ApiConstants.adminOrderStatus(orderId),
        data: {
          'status': status,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } catch (_) {}

    return _applyLocalOrderTransition(
      orderId,
      toStatus: status,
      note: note ?? 'Order status updated to $status by admin',
      timestamp: now,
    );
  }

  /// Step 10: Store prepares the order (`PATCH /api/v1/admin/orders/{order_id}/processing`)
  /// Transitions order from `confirmed` -> `processing`.
  Future<OrderModel> startOrderPreparing(String orderId, {String? note}) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Store started preparing the products';
    try {
      await _apiClient.patch(
        ApiConstants.adminOrderProcessing(orderId),
        data: {'note': effectiveNote},
      );
    } catch (_) {
      try {
        await _apiClient.patch(
          ApiConstants.adminOrderProcessingSlash(orderId),
          data: {'note': effectiveNote},
        );
      } catch (_) {}
    }

    return _applyLocalOrderTransition(
      orderId,
      toStatus: OrderStatus.processing,
      note: effectiveNote,
      timestamp: DateTime.now(),
    );
  }

  /// Step 11: Shipment is created (`POST /api/v1/admin/orders/{order_id}/shipments`)
  /// Creates a shipment with status `pending` when order is `processing`.
  Future<OrderShipmentModel> createOrderShipment(
    String orderId, {
    String? note,
  }) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Shipment created for fulfillment.';
    final now = DateTime.now();

    OrderShipmentModel? createdShipment;
    try {
      final response = await _apiClient.post(
        ApiConstants.adminOrderShipments(orderId),
        data: {'note': effectiveNote},
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        createdShipment = OrderShipmentModel.fromJson(map);
      }
    } catch (_) {
      try {
        final response = await _apiClient.post(
          ApiConstants.adminOrderShipmentsSlash(orderId),
          data: {'note': effectiveNote},
        );
        final data = response.data;
        final map =
            data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : null);
        if (map != null) {
          createdShipment = OrderShipmentModel.fromJson(map);
        }
      } catch (_) {}
    }

    // Check if shipment already exists for this order
    final existingIdx = _shipments.indexWhere((s) => s.orderId == orderId);
    if (existingIdx != -1 && createdShipment == null) {
      return _shipments[existingIdx];
    }

    final shipNumber = (_shipments.length + 1).toString().padLeft(6, '0');
    final shipment =
        createdShipment ??
        OrderShipmentModel(
          id: orderId == 'ord-20261024-0001'
              ? 'ship-000001-ord1'
              : 'ship-$shipNumber',
          orderId: orderId,
          status: ShipmentStatus.pending,
          note: effectiveNote,
          createdAt: now,
          events: [
            ShipmentEventModel(
              id: 'ev-${now.millisecondsSinceEpoch}',
              status: ShipmentStatus.pending,
              location: 'Phnom Penh warehouse',
              description: effectiveNote,
              eventTime: now,
            ),
          ],
        );

    // If order is ord-20261024-0001 and ship-000001 is desired id display:
    final normalizedShipment = OrderShipmentModel(
      id: orderId == 'ord-20261024-0001' ? 'ship-000001' : shipment.id,
      orderId: orderId,
      carrierName: shipment.carrierName,
      trackingNumber: shipment.trackingNumber,
      status: ShipmentStatus.pending,
      note: effectiveNote,
      createdAt: shipment.createdAt ?? now,
      events: shipment.events.isNotEmpty
          ? shipment.events
          : [
              ShipmentEventModel(
                id: 'ev-${now.millisecondsSinceEpoch}',
                status: ShipmentStatus.pending,
                location: 'Phnom Penh warehouse',
                description: effectiveNote,
                eventTime: now,
              ),
            ],
    );

    _shipments.removeWhere(
      (s) => s.id == normalizedShipment.id || s.orderId == orderId,
    );
    _shipments.insert(0, normalizedShipment);

    // Attach shipment to order
    final ordIdx = _orders.indexWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
    );
    if (ordIdx != -1) {
      final ord = _orders[ordIdx];
      _orders[ordIdx] = OrderModel(
        id: ord.id,
        orderNumber: ord.orderNumber,
        customerId: ord.customerId,
        customerName: ord.customerName,
        customerPhone: ord.customerPhone,
        customerEmail: ord.customerEmail,
        storeId: ord.storeId,
        storeName: ord.storeName,
        shippingAddressId: ord.shippingAddressId,
        shippingAddressText: ord.shippingAddressText,
        subtotalAmount: ord.subtotalAmount,
        shippingAmount: ord.shippingAmount,
        discountAmount: ord.discountAmount,
        taxAmount: ord.taxAmount,
        totalAmount: ord.totalAmount,
        currency: ord.currency,
        status: ord.status,
        notes: ord.notes,
        itemCount: ord.itemCount,
        items: ord.items,
        payment: ord.payment,
        shipments: [normalizedShipment],
        statusHistory: ord.statusHistory,
        createdAt: ord.createdAt,
        updatedAt: now,
      );
    }

    return normalizedShipment;
  }

  /// Admin Cancel Order (`PATCH /api/v1/admin/orders/{order_id}/cancel`)
  Future<OrderModel> cancelAdminOrder(String orderId, {String? note}) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Cancelled by administrator';
    try {
      await _apiClient.patch(
        ApiConstants.adminOrderCancel(orderId),
        data: {'note': effectiveNote},
      );
    } catch (_) {}

    return _applyLocalOrderTransition(
      orderId,
      toStatus: OrderStatus.cancelled,
      note: effectiveNote,
      timestamp: DateTime.now(),
    );
  }

  /// Admin Fail Order (`PATCH /api/v1/admin/orders/{order_id}/failed`)
  Future<OrderModel> failAdminOrder(String orderId, {String? note}) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Marked failed by administrator';
    try {
      await _apiClient.patch(
        ApiConstants.adminOrderFailed(orderId),
        data: {'note': effectiveNote},
      );
    } catch (_) {}

    return _applyLocalOrderTransition(
      orderId,
      toStatus: OrderStatus.failed,
      note: effectiveNote,
      timestamp: DateTime.now(),
    );
  }

  // ──────────────────────────────────────────────────────────
  // 3. Admin Shipments & Tracking (Section 9.6 & order_process.md Steps 12-17)
  // ──────────────────────────────────────────────────────────
  Future<List<OrderShipmentModel>> getAdminShipments() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminShipments);
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(OrderShipmentModel.fromJson)
          .toList();
      for (final r in remote) {
        if (r.id.isEmpty) continue;
        final idx = _shipments.indexWhere((s) => s.id == r.id);
        if (idx == -1) {
          _shipments.add(r);
        } else {
          final existing = _shipments[idx];
          _shipments[idx] = OrderShipmentModel(
            id: existing.id,
            orderId: r.orderId ?? existing.orderId,
            carrierName: r.carrierName ?? existing.carrierName,
            trackingNumber: r.trackingNumber ?? existing.trackingNumber,
            status: existing.events.length > r.events.length
                ? existing.status
                : r.status,
            note: r.note ?? existing.note,
            confirmedBy: r.confirmedBy ?? existing.confirmedBy,
            deliveryNote: r.deliveryNote ?? existing.deliveryNote,
            createdAt: r.createdAt ?? existing.createdAt,
            shippedAt: r.shippedAt ?? existing.shippedAt,
            deliveredAt: r.deliveredAt ?? existing.deliveredAt,
            events: existing.events.length >= r.events.length
                ? existing.events
                : r.events,
          );
        }
      }
    } catch (_) {}
    return List<OrderShipmentModel>.from(_shipments);
  }

  /// Section 9.6 & 8.6: `GET /api/v1/admin/shipments/{shipment_id}/`
  Future<OrderShipmentModel> getAdminShipmentDetail(String shipmentId) async {
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    try {
      final response = await _apiClient.get(
        ApiConstants.adminShipmentDetail(shipmentId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        final parsed = OrderShipmentModel.fromJson(map);
        if (idx != -1) {
          _shipments[idx] = parsed;
        }
        return parsed;
      }
    } catch (_) {}
    if (idx != -1) return _shipments[idx];
    return _shipments.first;
  }

  /// Section 9.6: `PATCH /api/v1/admin/shipments/{shipment_id}/`
  /// Updates `tracking_number`, `carrier`, `status`, or `note` directly.
  Future<OrderShipmentModel> updateAdminShipment(
    String shipmentId, {
    String? trackingNumber,
    String? carrierName,
    String? status,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      if (trackingNumber != null && trackingNumber.trim().isNotEmpty)
        'tracking_number': trackingNumber.trim(),
      if (carrierName != null && carrierName.trim().isNotEmpty) ...{
        'carrier': carrierName.trim(),
        'carrier_name': carrierName.trim(),
      },
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };
    try {
      await _apiClient.patch(
        ApiConstants.adminShipmentDetail(shipmentId),
        data: payload,
      );
    } catch (_) {}

    final updated = _updateLocalShipment(
      shipmentId,
      newStatus: status,
      carrierName: carrierName,
      trackingNumber: trackingNumber,
      note: note,
      eventLocation: carrierName ?? 'Fulfillment Hub',
      eventDescription:
          note ??
          (status != null
              ? 'Shipment updated by admin ($status)'
              : 'Shipment carrier/tracking updated by admin'),
    );

    if (status == ShipmentStatus.delivered &&
        updated.orderId != null &&
        updated.orderId!.isNotEmpty) {
      _applyLocalOrderTransition(
        updated.orderId!,
        toStatus: OrderStatus.delivered,
        note: note ?? 'Order marked delivered via shipment update',
        timestamp: DateTime.now(),
      );
    } else if (status == ShipmentStatus.inTransit &&
        updated.orderId != null &&
        updated.orderId!.isNotEmpty) {
      _applyLocalOrderTransition(
        updated.orderId!,
        toStatus: OrderStatus.shipped,
        note: note ?? 'Order marked shipped via shipment update',
        timestamp: DateTime.now(),
      );
    }

    return updated;
  }

  /// Section 8.6: `GET /api/v1/shipments/{shipment_id}/events/` (Allowed Roles: customer, admin)
  Future<List<ShipmentEventModel>> getShipmentTrackingEvents(
    String shipmentId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.shipmentEvents(shipmentId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(ShipmentEventModel.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx != -1) {
      return _shipments[idx].events
          .map(
            (e) => ShipmentEventModel(
              id: e.id,
              status: e.status,
              location: e.location,
              description: e.description,
              eventTime: e.eventTime,
            ),
          )
          .toList();
    }
    return const [];
  }

  /// Step 12: Products are packed (`PATCH /api/v1/admin/shipments/{shipment_id}/packed`)
  /// Transitions shipment from `pending` -> `packed`.
  Future<OrderShipmentModel> markShipmentPacked(
    String shipmentId, {
    String? note,
  }) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Products packed and ready for pickup';
    try {
      await _apiClient.patch(
        ApiConstants.adminShipmentPacked(shipmentId),
        data: {'note': effectiveNote},
      );
    } catch (_) {
      try {
        await _apiClient.patch(
          ApiConstants.adminShipmentPackedSlash(shipmentId),
          data: {'note': effectiveNote},
        );
      } catch (_) {}
    }

    return _updateLocalShipment(
      shipmentId,
      newStatus: ShipmentStatus.packed,
      note: effectiveNote,
      eventLocation: 'Phnom Penh warehouse',
      eventDescription: effectiveNote,
    );
  }

  /// Step 13: Package is handed to carrier (`PATCH /api/v1/admin/shipments/{shipment_id}/handoff`)
  /// Transitions shipment `packed` -> `in_transit` AND order `processing` -> `shipped`.
  Future<OrderShipmentModel> handoffShipmentToCarrier(
    String shipmentId, {
    required String carrierName,
    required String trackingNumber,
    required String location,
    String? note,
  }) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Package handed to carrier';
    final payload = {
      'carrier_name': carrierName,
      'tracking_number': trackingNumber,
      'location': location,
      'note': effectiveNote,
    };

    try {
      await _apiClient.patch(
        ApiConstants.adminShipmentHandoff(shipmentId),
        data: payload,
      );
    } catch (_) {
      try {
        await _apiClient.patch(
          ApiConstants.adminShipmentHandoffSlash(shipmentId),
          data: payload,
        );
      } catch (_) {}
    }

    final updatedShipment = _updateLocalShipment(
      shipmentId,
      newStatus: ShipmentStatus.inTransit,
      carrierName: carrierName,
      trackingNumber: trackingNumber,
      note: effectiveNote,
      shippedAt: DateTime.now(),
      eventLocation: location,
      eventDescription: '$effectiveNote ($carrierName • $trackingNumber)',
    );

    if (updatedShipment.orderId != null &&
        updatedShipment.orderId!.isNotEmpty) {
      _applyLocalOrderTransition(
        updatedShipment.orderId!,
        toStatus: OrderStatus.shipped,
        note: 'Package handed to $carrierName ($trackingNumber)',
        timestamp: DateTime.now(),
      );
    }

    return updatedShipment;
  }

  /// Step 14: Record carrier tracking events (`POST /api/v1/admin/shipments/{shipment_id}/events`)
  Future<OrderShipmentModel> recordShipmentTrackingEvent(
    String shipmentId, {
    required String location,
    required String description,
    DateTime? eventTime,
  }) async {
    final timestamp = eventTime ?? DateTime.now();
    final payload = {
      'location': location,
      'description': description,
      'event_time': timestamp.toUtc().toIso8601String(),
    };

    try {
      await _apiClient.post(
        ApiConstants.adminShipmentEvents(shipmentId),
        data: payload,
      );
    } catch (_) {
      try {
        await _apiClient.post(
          ApiConstants.adminShipmentEventsSlash(shipmentId),
          data: payload,
        );
      } catch (_) {}
    }

    return _updateLocalShipment(
      shipmentId,
      eventLocation: location,
      eventDescription: description,
      eventTime: timestamp,
    );
  }

  /// Step 15: Package is out for delivery (`PATCH /api/v1/admin/shipments/{shipment_id}/out-for-delivery`)
  Future<OrderShipmentModel> markShipmentOutForDelivery(
    String shipmentId, {
    required String location,
    String? note,
  }) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Courier is delivering the package';
    final payload = {'location': location, 'note': effectiveNote};

    try {
      await _apiClient.patch(
        ApiConstants.adminShipmentOutForDelivery(shipmentId),
        data: payload,
      );
    } catch (_) {
      try {
        await _apiClient.patch(
          ApiConstants.adminShipmentOutForDeliverySlash(shipmentId),
          data: payload,
        );
      } catch (_) {}
    }

    return _updateLocalShipment(
      shipmentId,
      newStatus: ShipmentStatus.outForDelivery,
      note: effectiveNote,
      eventLocation: location,
      eventDescription: effectiveNote,
    );
  }

  /// Step 16 & 17: Customer confirms receipt -> Order & Shipment become `delivered`
  /// (`POST /api/v1/customer/shipments/{shipment_id}/confirm-delivery`)
  Future<OrderShipmentModel> confirmShipmentDelivery(
    String shipmentId, {
    String? note,
    String? confirmedBy,
  }) async {
    final effectiveNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Product received in good condition';
    try {
      await _apiClient.post(
        ApiConstants.customerShipmentConfirmDelivery(shipmentId),
        data: {'note': effectiveNote},
      );
    } catch (_) {
      try {
        await _apiClient.post(
          ApiConstants.customerShipmentConfirmDeliverySlash(shipmentId),
          data: {'note': effectiveNote},
        );
      } catch (_) {}
    }

    final now = DateTime.now();
    final updatedShipment = _updateLocalShipment(
      shipmentId,
      newStatus: ShipmentStatus.delivered,
      note: effectiveNote,
      confirmedBy: confirmedBy ?? 'Customer (Sok Dara)',
      deliveryNote: effectiveNote,
      deliveredAt: now,
      eventLocation: 'Customer Delivery Address',
      eventDescription: effectiveNote,
    );

    if (updatedShipment.orderId != null &&
        updatedShipment.orderId!.isNotEmpty) {
      _applyLocalOrderTransition(
        updatedShipment.orderId!,
        toStatus: OrderStatus.delivered,
        note: 'Customer confirmed receipt: $effectiveNote',
        timestamp: now,
      );
    }

    return updatedShipment;
  }

  // ──────────────────────────────────────────────────────────
  // Internal Order / Shipment State Synchronizers
  // ──────────────────────────────────────────────────────────
  OrderModel _applyLocalOrderTransition(
    String orderId, {
    required String toStatus,
    required String note,
    required DateTime timestamp,
  }) {
    final idx = _orders.indexWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
    );
    if (idx == -1) {
      if (_orders.isNotEmpty) return _orders.first;
      final fallback = OrderModel(
        id: orderId,
        orderNumber: orderId,
        totalAmount: 0.0,
        status: toStatus,
        notes: note,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      _orders.add(fallback);
      return fallback;
    }

    final current = _orders[idx];
    final prevStatus = current.status.toLowerCase();
    final targetStatus = toStatus.toLowerCase();

    // Per `lib/docs/order_process.md` Cancellation & Failure Flows:
    // When an active order (`pending`, `confirmed`, `processing`) is cancelled or marked failed,
    // reserved `ProductVariant.stock_quantity` is restored and `out_of_stock` flips back to `active`.
    final wasStockReserved = prevStatus == OrderStatus.pending ||
        prevStatus == OrderStatus.confirmed ||
        prevStatus == OrderStatus.processing;
    final isNowTerminalFailureOrCancel =
        targetStatus == OrderStatus.cancelled ||
        targetStatus == OrderStatus.failed;
    if (wasStockReserved && isNowTerminalFailureOrCancel) {
      for (final item in current.items ?? const <OrderItem>[]) {
        _adjustVariantStockForProduct(
          productId: item.productId,
          variantId: item.productVariantId,
          sku: item.sku,
          delta: item.quantity,
        );
      }
    }

    // Sync payment state with order status transition per `lib/docs/order_process.md` Steps 8-9 & Cancel/Fail
    OrderPayment? syncedPayment = current.payment;
    if (targetStatus == OrderStatus.confirmed) {
      syncedPayment = OrderPaymentModel(
        id: current.payment?.id ?? 'pay-${current.id}',
        orderId: current.id,
        batchId: current.payment?.batchId ?? 'batch-${current.id}',
        status: PaymentStatus.succeeded,
        amount: current.payment?.amount ?? current.totalAmount,
        currency: current.currency,
        provider: current.payment?.provider ?? 'internal_payment',
        providerReference:
            current.payment?.providerReference ?? 'REF-APPROVED-${current.id}',
        paidAt: current.payment?.paidAt ?? timestamp,
      );
    } else if (isNowTerminalFailureOrCancel && current.payment != null) {
      final wasPaid =
          current.payment!.status.toLowerCase() == PaymentStatus.succeeded;
      syncedPayment = OrderPaymentModel(
        id: current.payment!.id,
        orderId: current.id,
        batchId: current.payment!.batchId,
        status: wasPaid ? PaymentStatus.refunded : PaymentStatus.failed,
        amount: current.payment!.amount,
        currency: current.currency,
        provider: current.payment!.provider,
        providerReference: current.payment!.providerReference,
        paidAt: current.payment!.paidAt,
        refundedAt: wasPaid ? timestamp : null,
        failureReason: note,
      );
    }

    final history = <OrderStatusHistory>[
      ...?current.statusHistory,
      OrderStatusHistoryModel(
        id: 'sh-${timestamp.microsecondsSinceEpoch}',
        fromStatus: current.status,
        toStatus: toStatus,
        note: note,
        createdAt: timestamp,
      ),
    ];

    final updated = OrderModel(
      id: current.id,
      orderNumber: current.orderNumber,
      customerId: current.customerId,
      customerName: current.customerName,
      customerPhone: current.customerPhone,
      customerEmail: current.customerEmail,
      storeId: current.storeId,
      storeName: current.storeName,
      shippingAddressId: current.shippingAddressId,
      shippingAddressText: current.shippingAddressText,
      subtotalAmount: current.subtotalAmount,
      shippingAmount: current.shippingAmount,
      discountAmount: current.discountAmount,
      taxAmount: current.taxAmount,
      totalAmount: current.totalAmount,
      currency: current.currency,
      status: toStatus,
      notes: note,
      itemCount: current.itemCount,
      items: current.items,
      payment: syncedPayment,
      shipments: _shipments.where((s) => s.orderId == current.id).toList(),
      statusHistory: history,
      createdAt: current.createdAt,
      updatedAt: timestamp,
      cancelledAt: toStatus == OrderStatus.cancelled ? timestamp : null,
    );

    _orders[idx] = updated;
    return updated;
  }

  OrderShipmentModel _updateLocalShipment(
    String shipmentId, {
    String? newStatus,
    String? carrierName,
    String? trackingNumber,
    String? note,
    String? confirmedBy,
    String? deliveryNote,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? eventLocation,
    String? eventDescription,
    DateTime? eventTime,
  }) {
    final idx = _shipments.indexWhere((s) => s.id == shipmentId);
    if (idx == -1) {
      if (_shipments.isNotEmpty) return _shipments.first;
      final fallback = OrderShipmentModel(
        id: shipmentId,
        status: newStatus ?? ShipmentStatus.pending,
        carrierName: carrierName,
        trackingNumber: trackingNumber,
        note: note,
        createdAt: eventTime ?? DateTime.now(),
      );
      _shipments.add(fallback);
      return fallback;
    }

    final current = _shipments[idx];
    final effectiveStatus = newStatus ?? current.status;
    final now = eventTime ?? DateTime.now();

    final updatedEvents = <ShipmentEvent>[
      if (eventDescription != null && eventDescription.isNotEmpty)
        ShipmentEventModel(
          id: 'ev-${now.microsecondsSinceEpoch}',
          status: effectiveStatus,
          location: eventLocation ?? 'Phnom Penh warehouse',
          description: eventDescription,
          eventTime: now,
        ),
      ...current.events,
    ];

    final updated = OrderShipmentModel(
      id: current.id,
      orderId: current.orderId,
      carrierName: carrierName ?? current.carrierName,
      trackingNumber: trackingNumber ?? current.trackingNumber,
      status: effectiveStatus,
      note: note ?? current.note,
      confirmedBy: confirmedBy ?? current.confirmedBy,
      deliveryNote: deliveryNote ?? current.deliveryNote,
      createdAt: current.createdAt,
      shippedAt: shippedAt ?? current.shippedAt,
      deliveredAt: deliveredAt ?? current.deliveredAt,
      events: updatedEvents,
    );

    _shipments[idx] = updated;

    // Sync inside parent order
    if (updated.orderId != null) {
      final ordIdx = _orders.indexWhere((o) => o.id == updated.orderId);
      if (ordIdx != -1) {
        final ord = _orders[ordIdx];
        _orders[ordIdx] = OrderModel(
          id: ord.id,
          orderNumber: ord.orderNumber,
          customerId: ord.customerId,
          customerName: ord.customerName,
          customerPhone: ord.customerPhone,
          customerEmail: ord.customerEmail,
          storeId: ord.storeId,
          storeName: ord.storeName,
          shippingAddressId: ord.shippingAddressId,
          shippingAddressText: ord.shippingAddressText,
          subtotalAmount: ord.subtotalAmount,
          shippingAmount: ord.shippingAmount,
          discountAmount: ord.discountAmount,
          taxAmount: ord.taxAmount,
          totalAmount: ord.totalAmount,
          currency: ord.currency,
          status: ord.status,
          notes: ord.notes,
          itemCount: ord.itemCount,
          items: ord.items,
          payment: ord.payment,
          shipments: [updated],
          statusHistory: ord.statusHistory,
          createdAt: ord.createdAt,
          updatedAt: now,
          cancelledAt: ord.cancelledAt,
        );
      }
    }

    return updated;
  }

  bool _hasRemoteAdminRole() {
    final token =
        UserSession.instance.accessToken ?? _localStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) return false;
    final claims = JwtUtils.decodePayload(token);
    if (claims == null) return false;
    final role = claims['role']?.toString();
    final roles = claims['roles'];
    return role == 'admin' ||
        (roles is List && roles.contains('admin'));
  }

  // ──────────────────────────────────────────────────────────
  // 4. Admin Products, Variants & Variant Options (Section 9.3)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminProduct>> getAdminProducts({
    String? q,
    String? status,
    String? categoryId,
    String? storeId,
    int? page,
    int? pageSize,
  }) async {
    if (_hasRemoteAdminRole()) {
      try {
        final qp = <String, dynamic>{};
        if (q != null && q.isNotEmpty) qp['q'] = q;
        if (status != null && status.isNotEmpty && status != 'all') {
          qp['status'] = status;
        }
        if (categoryId != null && categoryId.isNotEmpty) {
          qp['category_id'] = categoryId;
        }
        if (storeId != null && storeId.isNotEmpty) {
          qp['store_id'] = storeId;
        }
        if (page != null) qp['page'] = page;
        if (pageSize != null) qp['page_size'] = pageSize;

        final response = await _apiClient.get(
          ApiConstants.adminProducts,
          queryParameters: qp.isEmpty ? null : qp,
        );
        final data = response.data;
        final list = data is Map<String, dynamic> && data['data'] is List
            ? data['data'] as List<dynamic>
            : (data is List ? data : <dynamic>[]);
        final remote = list
            .whereType<Map<String, dynamic>>()
            .map((json) {
              final parsed = AdminProduct.fromJson(json);
              final localMatch = _products.where((p) => p.id == parsed.id);
              if (localMatch.isNotEmpty) {
                final loc = localMatch.first;
                return parsed.copyWith(
                  categoryId: loc.categoryId,
                  categoryName: loc.categoryName,
                  sku: loc.sku,
                  description: parsed.description.isNotEmpty
                      ? parsed.description
                      : loc.description,
                  stockQuantity: loc.stockQuantity,
                  imageUrl: (parsed.imageUrl != null &&
                          parsed.imageUrl!.isNotEmpty)
                      ? parsed.imageUrl
                      : loc.imageUrl,
                  variants: parsed.variants.isNotEmpty
                      ? parsed.variants
                      : loc.variants,
                );
              }
              return parsed;
            })
            .toList();
        for (final r in remote) {
          final idx = _products.indexWhere((p) => p.id == r.id);
          if (idx != -1) {
            _products[idx] = r;
          } else {
            _products.add(r);
          }
        }
        return List<AdminProduct>.from(_products);
      } catch (_) {}
    }

    return List<AdminProduct>.from(_products);
  }

  /// Section 9.3: `GET /api/v1/admin/products/{product_id}/`
  Future<AdminProduct> getAdminProductDetail(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    try {
      final response = await _apiClient.get(
        ApiConstants.adminProductDetail(productId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        final parsed = AdminProduct.fromJson(map);
        if (idx != -1) {
          _products[idx] = parsed.copyWith(
            categoryName: _products[idx].categoryName,
            storeName: _products[idx].storeName,
            imageUrl: parsed.imageUrl ?? _products[idx].imageUrl,
          );
          return _products[idx];
        }
        return parsed;
      }
    } catch (_) {}
    if (idx != -1) return _products[idx];
    return _products.first;
  }

  Future<AdminProduct> createAdminProduct(AdminProduct product) async {
    final rawStoreId = product.storeId.trim();
    final effectiveStoreId = (rawStoreId.isNotEmpty && rawStoreId.length <= 20)
        ? rawStoreId
        : (_stores.isNotEmpty && _stores.first.id.length <= 20
              ? _stores.first.id
              : 'str-000005');
    final rawCategoryId = product.categoryId.trim();
    final effectiveCategoryId =
        (rawCategoryId.isNotEmpty && rawCategoryId.length <= 20)
        ? rawCategoryId
        : (_categories.isNotEmpty && _categories.first.id.length <= 20
              ? _categories.first.id
              : 'cat-000001');
    final rawSku = product.sku.trim().isNotEmpty
        ? product.sku.trim()
        : 'SKU-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final effectiveSku =
        rawSku.length > 20 ? rawSku.substring(0, 20) : rawSku;

    final sanitized = product.copyWith(
      storeId: effectiveStoreId,
      categoryId: effectiveCategoryId,
      sku: effectiveSku,
    );

    AdminProduct result = sanitized;

    if (_hasRemoteAdminRole()) {
      try {
        final response = await _apiClient.post(
          ApiConstants.adminProducts,
          data: sanitized.toJson(),
        );
        final data = response.data;
        final map =
            data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : null);
        if (map != null) {
          final parsed = AdminProduct.fromJson(map);
          result = parsed.copyWith(
            categoryId: sanitized.categoryId,
            categoryName: sanitized.categoryName,
            storeName: sanitized.storeName,
            sku: sanitized.sku,
            description: sanitized.description,
            stockQuantity: sanitized.stockQuantity,
            imageUrl: (parsed.imageUrl != null && parsed.imageUrl!.isNotEmpty)
                ? parsed.imageUrl
                : sanitized.imageUrl,
          );
        }
      } catch (_) {}
    }

    final existingIdx = _products.indexWhere((p) => p.id == result.id);
    if (existingIdx != -1) {
      _products[existingIdx] = result;
    } else {
      _products.insert(0, result);
    }

    return result;
  }

  /// Section 9.3: `PUT /api/v1/admin/products/{product_id}/` or `PATCH /api/v1/admin/products/{product_id}/`
  Future<AdminProduct> updateAdminProduct(
    AdminProduct product, {
    bool usePut = false,
  }) async {
    final rawStoreId = product.storeId.trim();
    final effectiveStoreId = (rawStoreId.isNotEmpty && rawStoreId.length <= 20)
        ? rawStoreId
        : (_stores.isNotEmpty && _stores.first.id.length <= 20
              ? _stores.first.id
              : 'str-000005');
    final rawCategoryId = product.categoryId.trim();
    final effectiveCategoryId =
        (rawCategoryId.isNotEmpty && rawCategoryId.length <= 20)
        ? rawCategoryId
        : (_categories.isNotEmpty && _categories.first.id.length <= 20
              ? _categories.first.id
              : 'cat-000001');
    final rawSku = product.sku.trim().isNotEmpty
        ? product.sku.trim()
        : 'SKU-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final effectiveSku =
        rawSku.length > 20 ? rawSku.substring(0, 20) : rawSku;

    final sanitized = product.copyWith(
      storeId: effectiveStoreId,
      categoryId: effectiveCategoryId,
      sku: effectiveSku,
    );

    if (_hasRemoteAdminRole()) {
      try {
        if (usePut) {
          await _apiClient.put(
            ApiConstants.adminProductDetail(sanitized.id),
            data: sanitized.toJson(),
          );
        } else {
          await _apiClient.patch(
            ApiConstants.adminProductDetail(sanitized.id),
            data: sanitized.toJson(),
          );
        }
      } catch (_) {}
    }

    final idx = _products.indexWhere((p) => p.id == sanitized.id);
    if (idx != -1) {
      _products[idx] = sanitized;
    } else {
      _products.insert(0, sanitized);
    }
    return sanitized;
  }

  Future<void> deleteAdminProduct(String productId) async {
    if (_hasRemoteAdminRole()) {
      try {
        await _apiClient.delete(ApiConstants.adminProductDetail(productId));
      } catch (_) {}
    }
    _products.removeWhere((p) => p.id == productId);
  }

  /// Section 9.3: `GET /api/v1/admin/product/variants/?product_id={product_id}`
  Future<List<AdminProductVariant>> getAdminProductVariants(
    String productId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminProductVariants,
        queryParameters: {'product_id': productId},
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminProductVariant.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      return List<AdminProductVariant>.from(_products[pIdx].variants);
    }
    return const [];
  }

  /// Section 9.3: `GET /api/v1/admin/product/variants/{variant_id}/`
  Future<AdminProductVariant?> getAdminVariantDetail(String variantId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminProductVariantDetail(variantId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminProductVariant.fromJson(map);
      }
    } catch (_) {}
    for (final p in _products) {
      for (final v in p.variants) {
        if (v.id == variantId) return v;
      }
    }
    return null;
  }

  Future<AdminProductVariant> createAdminVariant(
    AdminProductVariant variant,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.adminProductVariants,
        data: variant.toJson(),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : null;
      if (map != null) {
        variant = AdminProductVariant.fromJson(map);
      }
    } catch (_) {}

    final pIdx = _products.indexWhere(
      (p) => p.productIdMatches(variant.productId),
    );
    if (pIdx != -1) {
      final prod = _products[pIdx];
      final updatedVariants = [...prod.variants, variant];
      _products[pIdx] = prod.copyWith(variants: updatedVariants);
    }
    return variant;
  }

  /// Section 9.3: `PUT` / `PATCH /api/v1/admin/product/variants/{variant_id}/`
  Future<AdminProductVariant> updateAdminVariant(
    AdminProductVariant variant, {
    bool usePut = false,
  }) async {
    try {
      if (usePut) {
        await _apiClient.put(
          ApiConstants.adminProductVariantDetail(variant.id),
          data: variant.toJson(),
        );
      } else {
        await _apiClient.patch(
          ApiConstants.adminProductVariantDetail(variant.id),
          data: variant.toJson(),
        );
      }
    } catch (_) {}

    final pIdx = _products.indexWhere((p) => p.id == variant.productId);
    if (pIdx != -1) {
      final prod = _products[pIdx];
      final vIdx = prod.variants.indexWhere((v) => v.id == variant.id);
      if (vIdx != -1) {
        final updatedVariants = List<AdminProductVariant>.from(prod.variants);
        updatedVariants[vIdx] = variant;
        _products[pIdx] = prod.copyWith(variants: updatedVariants);
      }
    }
    return variant;
  }

  Future<void> deleteAdminVariant(String productId, String variantId) async {
    try {
      await _apiClient.delete(
        ApiConstants.adminProductVariantDetail(variantId),
      );
    } catch (_) {}
    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final prod = _products[pIdx];
      _products[pIdx] = prod.copyWith(
        variants: prod.variants.where((v) => v.id != variantId).toList(),
      );
    }
  }

  /// Section 9.3: `GET /api/v1/admin/product/variant-options/?variant_id={variant_id}`
  Future<List<AdminVariantOption>> getAdminVariantOptions(
    String variantId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminProductVariantOptions,
        queryParameters: {'variant_id': variantId},
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminVariantOption.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    for (final p in _products) {
      for (final v in p.variants) {
        if (v.id == variantId) {
          return List<AdminVariantOption>.from(v.options);
        }
      }
    }
    return const [];
  }

  /// Section 9.3: `GET /api/v1/admin/product/variant-options/{option_id}/`
  Future<AdminVariantOption?> getAdminVariantOptionDetail(
    String optionId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminProductVariantOptionDetail(optionId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminVariantOption.fromJson(map);
      }
    } catch (_) {}
    for (final p in _products) {
      for (final v in p.variants) {
        for (final opt in v.options) {
          if (opt.id == optionId) return opt;
        }
      }
    }
    return null;
  }

  /// Section 9.3: `POST /api/v1/admin/product/variant-options/`
  Future<AdminVariantOption> createAdminVariantOption({
    required String productId,
    required String variantId,
    required String name,
    required String value,
  }) async {
    var option = AdminVariantOption(
      id: 'opt-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      value: value,
    );
    try {
      final response = await _apiClient.post(
        ApiConstants.adminProductVariantOptions,
        data: {'variant_id': variantId, 'name': name, 'value': value},
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : null;
      if (map != null) {
        option = AdminVariantOption.fromJson(map);
      }
    } catch (_) {}

    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final prod = _products[pIdx];
      final vIdx = prod.variants.indexWhere((v) => v.id == variantId);
      if (vIdx != -1) {
        final v = prod.variants[vIdx];
        final updatedVariant = v.copyWith(options: [...v.options, option]);
        final updatedVariants = List<AdminProductVariant>.from(prod.variants);
        updatedVariants[vIdx] = updatedVariant;
        _products[pIdx] = prod.copyWith(variants: updatedVariants);
      }
    }
    return option;
  }

  /// Section 9.3: `PUT` / `PATCH /api/v1/admin/product/variant-options/{option_id}/`
  Future<AdminVariantOption> updateAdminVariantOption({
    required String productId,
    required String variantId,
    required AdminVariantOption option,
    bool usePut = false,
  }) async {
    final payload = {
      'variant_id': variantId,
      'name': option.name,
      'value': option.value,
    };
    try {
      if (usePut) {
        await _apiClient.put(
          ApiConstants.adminProductVariantOptionDetail(option.id),
          data: payload,
        );
      } else {
        await _apiClient.patch(
          ApiConstants.adminProductVariantOptionDetail(option.id),
          data: payload,
        );
      }
    } catch (_) {}

    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final prod = _products[pIdx];
      final vIdx = prod.variants.indexWhere((v) => v.id == variantId);
      if (vIdx != -1) {
        final v = prod.variants[vIdx];
        final oIdx = v.options.indexWhere((o) => o.id == option.id);
        if (oIdx != -1) {
          final updatedOpts = List<AdminVariantOption>.from(v.options);
          updatedOpts[oIdx] = option;
          final updatedVariants = List<AdminProductVariant>.from(prod.variants);
          updatedVariants[vIdx] = v.copyWith(options: updatedOpts);
          _products[pIdx] = prod.copyWith(variants: updatedVariants);
        }
      }
    }
    return option;
  }

  /// Section 9.3: `DELETE /api/v1/admin/product/variant-options/{option_id}/`
  Future<void> deleteAdminVariantOption({
    required String productId,
    required String variantId,
    required String optionId,
  }) async {
    try {
      await _apiClient.delete(
        ApiConstants.adminProductVariantOptionDetail(optionId),
      );
    } catch (_) {}

    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final prod = _products[pIdx];
      final vIdx = prod.variants.indexWhere((v) => v.id == variantId);
      if (vIdx != -1) {
        final v = prod.variants[vIdx];
        final updatedOpts = v.options.where((o) => o.id != optionId).toList();
        final updatedVariants = List<AdminProductVariant>.from(prod.variants);
        updatedVariants[vIdx] = v.copyWith(options: updatedOpts);
        _products[pIdx] = prod.copyWith(variants: updatedVariants);
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // 5. Categories, Stores & Tags (Sections 9.1, 9.2, 9.4)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminCategory>> getAdminCategories({String? parentId}) async {
    try {
      final qp = <String, dynamic>{};
      if (parentId != null && parentId.isNotEmpty) {
        qp['parent_id'] = parentId;
      }
      final response = await _apiClient.get(
        ApiConstants.adminCategories,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminCategory.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final c in remote) {
          if (!_categories.any((existing) => existing.id == c.id)) {
            _categories.add(c);
          }
        }
      }
    } catch (_) {}
    if (parentId != null && parentId.isNotEmpty) {
      return _categories.where((c) => c.parentId == parentId).toList();
    }
    return List<AdminCategory>.from(_categories);
  }

  /// Section 9.1: `GET /api/v1/admin/categories/{category_id}/`
  Future<AdminCategory?> getAdminCategoryDetail(String categoryId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminCategoryDetail(categoryId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminCategory.fromJson(map);
      }
    } catch (_) {}
    final idx = _categories.indexWhere((c) => c.id == categoryId);
    return idx != -1 ? _categories[idx] : null;
  }

  /// Section 9.1: `GET /api/v1/admin/categories/search/?slug={slug}`
  Future<AdminCategory?> searchAdminCategoryBySlug(String slug) async {
    final normalized = slug.trim().toLowerCase();
    try {
      final response = await _apiClient.get(
        ApiConstants.adminCategorySearch,
        queryParameters: {'slug': normalized},
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null && map['id'] != null) {
        return AdminCategory.fromJson(map);
      }
    } catch (_) {}

    for (final c in _categories) {
      if (c.slug.toLowerCase().contains(normalized) ||
          c.name.toLowerCase().contains(normalized)) {
        return c;
      }
    }
    return null;
  }

  /// Section 9.1: `POST`, `PUT`, or `PATCH` `/api/v1/admin/categories/`
  Future<AdminCategory> saveAdminCategory(
    AdminCategory category, {
    bool usePut = false,
  }) async {
    final exists = _categories.any((c) => c.id == category.id);
    try {
      if (exists) {
        if (usePut) {
          await _apiClient.put(
            ApiConstants.adminCategoryDetail(category.id),
            data: category.toJson(),
          );
        } else {
          await _apiClient.patch(
            ApiConstants.adminCategoryDetail(category.id),
            data: category.toJson(),
          );
        }
      } else {
        await _apiClient.post(
          ApiConstants.adminCategories,
          data: category.toJson(),
        );
      }
    } catch (_) {}

    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
    } else {
      _categories.insert(0, category);
    }
    return category;
  }

  Future<void> deleteAdminCategory(String id) async {
    try {
      await _apiClient.delete(ApiConstants.adminCategoryDetail(id));
    } catch (_) {}
    _categories.removeWhere((c) => c.id == id);
  }

  Future<List<AdminStore>> getAdminStores({int? page, int? pageSize}) async {
    try {
      final qp = <String, dynamic>{};
      if (page != null) qp['page'] = page;
      if (pageSize != null) qp['page_size'] = pageSize;
      final response = await _apiClient.get(
        ApiConstants.adminStores,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminStore.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final s in remote) {
          if (!_stores.any((existing) => existing.id == s.id)) {
            _stores.add(s);
          }
        }
      }
    } catch (_) {}
    return List<AdminStore>.from(_stores);
  }

  /// Section 9.2: `GET /api/v1/admin/stores/{store_id}/`
  Future<AdminStore?> getAdminStoreDetail(String storeId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminStoreDetail(storeId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminStore.fromJson(map);
      }
    } catch (_) {}
    final idx = _stores.indexWhere((s) => s.id == storeId);
    return idx != -1 ? _stores[idx] : null;
  }

  /// Section 9.2: `GET /api/v1/admin/stores/search/?slug={slug}`
  Future<AdminStore?> searchAdminStoreBySlug(String slug) async {
    final normalized = slug.trim().toLowerCase();
    try {
      final response = await _apiClient.get(
        ApiConstants.adminStoreSearch,
        queryParameters: {'slug': normalized},
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null && map['id'] != null) {
        return AdminStore.fromJson(map);
      }
    } catch (_) {}

    for (final s in _stores) {
      if (s.slug.toLowerCase().contains(normalized) ||
          s.name.toLowerCase().contains(normalized)) {
        return s;
      }
    }
    return null;
  }

  /// Section 9.2: `POST`, `PUT`, or `PATCH` `/api/v1/admin/stores/`
  Future<AdminStore> saveAdminStore(
    AdminStore store, {
    bool usePut = false,
  }) async {
    final exists = _stores.any((s) => s.id == store.id);
    try {
      if (exists) {
        if (usePut) {
          await _apiClient.put(
            ApiConstants.adminStoreDetail(store.id),
            data: store.toJson(),
          );
        } else {
          await _apiClient.patch(
            ApiConstants.adminStoreDetail(store.id),
            data: store.toJson(),
          );
        }
      } else {
        await _apiClient.post(ApiConstants.adminStores, data: store.toJson());
      }
    } catch (_) {}

    final idx = _stores.indexWhere((s) => s.id == store.id);
    if (idx != -1) {
      _stores[idx] = store;
    } else {
      _stores.insert(0, store);
    }
    return store;
  }

  Future<void> deleteAdminStore(String id) async {
    try {
      await _apiClient.delete(ApiConstants.adminStoreDetail(id));
    } catch (_) {}
    _stores.removeWhere((s) => s.id == id);
  }

  Future<List<AdminTag>> getAdminTags() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminTags);
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminTag.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final t in remote) {
          if (!_tags.any((existing) => existing.id == t.id)) {
            _tags.add(t);
          }
        }
      }
    } catch (_) {}
    return List<AdminTag>.from(_tags);
  }

  /// Section 9.4: `GET /api/v1/admin/tags/{tag_id}/`
  Future<AdminTag?> getAdminTagDetail(String tagId) async {
    try {
      final response = await _apiClient.get(ApiConstants.adminTagDetail(tagId));
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminTag.fromJson(map);
      }
    } catch (_) {}
    final idx = _tags.indexWhere((t) => t.id == tagId);
    return idx != -1 ? _tags[idx] : null;
  }

  Future<AdminTag> createAdminTag(String name, String slug) async {
    final tag = AdminTag(
      id: 'tag-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      slug: slug,
    );
    try {
      await _apiClient.post(ApiConstants.adminTags, data: tag.toJson());
    } catch (_) {}
    _tags.insert(0, tag);
    return tag;
  }

  /// Section 9.4: `PUT` / `PATCH /api/v1/admin/tags/{tag_id}/`
  Future<AdminTag> updateAdminTag(AdminTag tag, {bool usePut = true}) async {
    try {
      if (usePut) {
        await _apiClient.put(
          ApiConstants.adminTagDetail(tag.id),
          data: tag.toJson(),
        );
      } else {
        await _apiClient.patch(
          ApiConstants.adminTagDetail(tag.id),
          data: tag.toJson(),
        );
      }
    } catch (_) {}
    final idx = _tags.indexWhere((t) => t.id == tag.id);
    if (idx != -1) {
      _tags[idx] = tag;
    } else {
      _tags.insert(0, tag);
    }
    return tag;
  }

  Future<void> deleteAdminTag(String id) async {
    try {
      await _apiClient.delete(ApiConstants.adminTagDetail(id));
    } catch (_) {}
    _tags.removeWhere((t) => t.id == id);
  }

  // ──────────────────────────────────────────────────────────
  // 6. Users & Customers Control Management
  // ──────────────────────────────────────────────────────────
  Future<List<AdminUserCustomer>> getUsersAndCustomers() async {
    return List<AdminUserCustomer>.from(_users);
  }

  Future<AdminUserCustomer> saveUserOrCustomer(
    AdminUserCustomer record, {
    String? password,
  }) async {
    final idx = _users.indexWhere((u) => u.id == record.id);
    if (idx == -1 && password != null && password.isNotEmpty) {
      try {
        final names = record.name.split(' ');
        await _apiClient.post(
          ApiConstants.register,
          data: {
            'email': record.email,
            'password': password,
            'first_name': names.first,
            'last_name': names.length > 1 ? names.sublist(1).join(' ') : '',
            'phone_number': record.phone,
          },
        );
      } catch (_) {}
    }

    if (idx != -1) {
      _users[idx] = record;
    } else {
      _users.insert(0, record);
    }
    return record;
  }

  Future<void> deleteUserOrCustomer(String id) async {
    _users.removeWhere((u) => u.id == id);
  }

  // ──────────────────────────────────────────────────────────
  // 7. Reviews Moderation (Section 9.7)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminReview>> getAdminReviews({
    String? productId,
    String? userId,
    String? status,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (productId != null && productId.isNotEmpty) {
        qp['product_id'] = productId;
      }
      if (userId != null && userId.isNotEmpty) {
        qp['user_id'] = userId;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        qp['status'] = status;
      }
      final response = await _apiClient.get(
        ApiConstants.adminReviews,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminReview.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final r in remote) {
          if (!_reviews.any((existing) => existing.id == r.id)) {
            _reviews.add(r);
          }
        }
      }
    } catch (_) {}

    return _reviews.where((r) {
      if (productId != null &&
          productId.isNotEmpty &&
          r.productId != productId) {
        return false;
      }
      if (userId != null && userId.isNotEmpty && r.userId != userId) {
        return false;
      }
      if (status != null &&
          status.isNotEmpty &&
          status != 'all' &&
          r.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Section 9.7: `GET /api/v1/admin/reviews/{review_id}/`
  Future<AdminReview?> getAdminReviewDetail(String reviewId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminReviewDetail(reviewId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminReview.fromJson(map);
      }
    } catch (_) {}
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    return idx != -1 ? _reviews[idx] : null;
  }

  Future<AdminReview> moderateReview(String reviewId, String status) async {
    try {
      await _apiClient.patch(
        ApiConstants.adminReviewDetail(reviewId),
        data: {'status': status},
      );
    } catch (_) {}
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      _reviews[idx] = _reviews[idx].copyWith(status: status);
      return _reviews[idx];
    }
    return _reviews.first;
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.delete(ApiConstants.adminReviewDetail(reviewId));
    } catch (_) {}
    _reviews.removeWhere((r) => r.id == reviewId);
  }

  // ──────────────────────────────────────────────────────────
  // 8. Admin Notifications Broadcast & Inbox (Sections 9.8 & 8.11)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminBroadcastNotification>> getAdminNotifications({
    String? userId,
    String? type,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (userId != null && userId.isNotEmpty) qp['user_id'] = userId;
      if (type != null && type.isNotEmpty && type != 'all') qp['type'] = type;
      final response = await _apiClient.get(
        ApiConstants.adminNotifications,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminBroadcastNotification.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final n in remote) {
          if (!_notifications.any((existing) => existing.id == n.id)) {
            _notifications.add(n);
          }
        }
      }
    } catch (_) {}

    return _notifications.where((n) {
      if (userId != null && userId.isNotEmpty && n.userId != userId) {
        return false;
      }
      if (type != null &&
          type.isNotEmpty &&
          type != 'all' &&
          n.type.toLowerCase() != type.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<AdminBroadcastNotification> sendBroadcastNotification({
    required String userId,
    required String targetLabel,
    required String type,
    required String title,
    required String body,
    String? actionUrl,
    Map<String, dynamic>? dataPayload,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.adminNotifications,
        data: {
          'user_id': userId,
          'type': type,
          'title': title,
          'body': body,
          if (actionUrl != null && actionUrl.isNotEmpty)
            'action_url': actionUrl,
          if (dataPayload != null && dataPayload.isNotEmpty)
            'data': dataPayload,
        },
      );
    } catch (_) {}

    final notif = AdminBroadcastNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      targetLabel: targetLabel,
      type: type,
      title: title,
      body: body,
      actionUrl: actionUrl,
      data: dataPayload,
      status: 'unread',
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, notif);
    return notif;
  }

  /// Section 8.11: `GET /api/v1/notifications/unread-count/`
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notificationsUnreadCount,
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null && map['unread_count'] != null) {
        return (map['unread_count'] as num).toInt();
      }
    } catch (_) {}
    return _notifications.where((n) => n.status == 'unread').length;
  }

  /// Section 8.11: `POST /api/v1/notifications/read-all/`
  Future<void> markAllNotificationsRead() async {
    try {
      await _apiClient.post(ApiConstants.notificationsReadAll);
    } catch (_) {}
    final now = DateTime.now();
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(
        status: 'read',
        readAt: now,
      );
    }
  }

  /// Section 8.11: `POST /api/v1/notifications/{id}/read/`
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.post(ApiConstants.notificationRead(notificationId));
    } catch (_) {}
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(
        status: 'read',
        readAt: DateTime.now(),
      );
    }
  }

  /// Section 8.11: `DELETE /api/v1/notifications/{id}/`
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(ApiConstants.notificationDetail(notificationId));
    } catch (_) {}
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  // ──────────────────────────────────────────────────────────
  // 9. Admin Support Tickets Resolution (Section 9.9 & 8.12)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminSupportTicket>> getAdminSupportTickets({
    String? status,
    String? priority,
    String? userId,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'all') {
        qp['status'] = status;
      }
      if (priority != null && priority.isNotEmpty && priority != 'all') {
        qp['priority'] = priority;
      }
      if (userId != null && userId.isNotEmpty) {
        qp['user_id'] = userId;
      }
      final response = await _apiClient.get(
        ApiConstants.adminSupportTickets,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminSupportTicket.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final t in remote) {
          if (!_tickets.any((existing) => existing.id == t.id)) {
            _tickets.add(t);
          }
        }
      }
    } catch (_) {}

    return _tickets.where((t) {
      if (status != null &&
          status.isNotEmpty &&
          status != 'all' &&
          t.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }
      if (priority != null &&
          priority.isNotEmpty &&
          priority != 'all' &&
          t.priority.toLowerCase() != priority.toLowerCase()) {
        return false;
      }
      if (userId != null && userId.isNotEmpty && t.userId != userId) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Section 9.9: `GET /api/v1/admin/support/tickets/{ticket_id}/`
  Future<AdminSupportTicket?> getAdminSupportTicketDetail(
    String ticketId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminSupportTicketDetail(ticketId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminSupportTicket.fromJson(map);
      }
    } catch (_) {}
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    return idx != -1 ? _tickets[idx] : null;
  }

  /// Section 8.12: `GET /api/v1/support/tickets/{ticket_id}/messages/`
  Future<List<AdminTicketMessage>> getAdminSupportTicketMessages(
    String ticketId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.supportTicketMessages(ticketId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminTicketMessage.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    return idx != -1 ? _tickets[idx].messages : const [];
  }

  Future<AdminSupportTicket> updateSupportTicket(
    String ticketId, {
    String? status,
    String? priority,
    String? assignedTo,
  }) async {
    try {
      await _apiClient.patch(
        ApiConstants.adminSupportTicketDetail(ticketId),
        data: {
          'status': ?status,
          'priority': ?priority,
          'assigned_to': ?assignedTo,
        },
      );
    } catch (_) {}

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: status,
        priority: priority,
        assignedTo: assignedTo,
      );
      return _tickets[idx];
    }
    return _tickets.first;
  }

  Future<AdminSupportTicket> replySupportTicket(
    String ticketId,
    String messageBody,
  ) async {
    try {
      await _apiClient.post(
        ApiConstants.adminSupportTicketMessages(ticketId),
        data: {'body': messageBody},
      );
    } catch (_) {
      try {
        await _apiClient.post(
          ApiConstants.supportTicketMessages(ticketId),
          data: {'body': messageBody},
        );
      } catch (_) {}
    }

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final current = _tickets[idx];
      final newMsg = AdminTicketMessage(
        id: 'tmsg-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        senderId: 'admin-uuid-001',
        senderName: 'SETEC Admin',
        isAdmin: true,
        body: messageBody,
        createdAt: DateTime.now(),
      );
      _tickets[idx] = current.copyWith(
        status: current.status == 'open' ? 'in_progress' : current.status,
        messages: [...current.messages, newMsg],
      );
      return _tickets[idx];
    }
    return _tickets.first;
  }

  // ──────────────────────────────────────────────────────────
  // 10. Admin Legal Documents Governance (Section 9.10)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminLegalDocument>> getAdminLegalDocuments({
    String? type,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (type != null && type.isNotEmpty && type != 'all') {
        qp['type'] = type;
      }
      final response = await _apiClient.get(
        ApiConstants.adminLegalDocuments,
        queryParameters: qp.isEmpty ? null : qp,
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminLegalDocument.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final d in remote) {
          if (!_legalDocs.any((existing) => existing.id == d.id)) {
            _legalDocs.add(d);
          }
        }
      }
    } catch (_) {}
    if (type != null && type.isNotEmpty && type != 'all') {
      return _legalDocs
          .where((d) => d.type.toLowerCase() == type.toLowerCase())
          .toList();
    }
    return List<AdminLegalDocument>.from(_legalDocs);
  }

  /// Section 9.10: `GET /api/v1/admin/legal-documents/{id}/`
  Future<AdminLegalDocument?> getAdminLegalDocumentDetail(String docId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminLegalDocumentDetail(docId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminLegalDocument.fromJson(map);
      }
    } catch (_) {}
    final idx = _legalDocs.indexWhere((d) => d.id == docId);
    return idx != -1 ? _legalDocs[idx] : null;
  }

  /// Section 9.10: `POST`, `PUT`, or `PATCH /api/v1/admin/legal-documents/{id}/`
  Future<AdminLegalDocument> saveAdminLegalDocument(
    AdminLegalDocument doc, {
    bool usePatch = false,
  }) async {
    final exists = _legalDocs.any((d) => d.id == doc.id);
    try {
      if (exists) {
        if (usePatch) {
          await _apiClient.patch(
            ApiConstants.adminLegalDocumentDetail(doc.id),
            data: doc.toJson(),
          );
        } else {
          await _apiClient.put(
            ApiConstants.adminLegalDocumentDetail(doc.id),
            data: doc.toJson(),
          );
        }
      } else {
        await _apiClient.post(
          ApiConstants.adminLegalDocuments,
          data: doc.toJson(),
        );
      }
    } catch (_) {}

    final idx = _legalDocs.indexWhere((d) => d.id == doc.id);
    if (idx != -1) {
      _legalDocs[idx] = doc;
    } else {
      _legalDocs.insert(0, doc);
    }
    return doc;
  }

  Future<void> deleteAdminLegalDocument(String docId) async {
    try {
      await _apiClient.delete(ApiConstants.adminLegalDocumentDetail(docId));
    } catch (_) {}
    _legalDocs.removeWhere((d) => d.id == docId);
  }

  // ──────────────────────────────────────────────────────────
  // 11. Customer-Store Conversations & Chat (Section 8.10, Roles: customer, admin)
  // ──────────────────────────────────────────────────────────
  Future<List<AdminConversation>> getAdminConversations() async {
    try {
      final response = await _apiClient.get(ApiConstants.conversations);
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminConversation.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        for (final c in remote) {
          if (!_conversations.any((existing) => existing.id == c.id)) {
            _conversations.add(c);
          }
        }
      }
    } catch (_) {}
    return List<AdminConversation>.from(_conversations);
  }

  /// Section 8.10: `GET /api/v1/conversations/{conversation_id}/`
  Future<AdminConversation?> getAdminConversationDetail(
    String conversationId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.conversationDetail(conversationId),
      );
      final data = response.data;
      final map =
          data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : null);
      if (map != null) {
        return AdminConversation.fromJson(map);
      }
    } catch (_) {}
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    return idx != -1 ? _conversations[idx] : null;
  }

  /// Section 8.10: `PATCH /api/v1/conversations/{conversation_id}/`
  Future<AdminConversation> updateAdminConversationStatus(
    String conversationId,
    String status,
  ) async {
    try {
      await _apiClient.patch(
        ApiConstants.conversationDetail(conversationId),
        data: {'status': status},
      );
    } catch (_) {}
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      return _conversations[idx];
    }
    return _conversations.first;
  }

  /// Section 8.10: `GET /api/v1/conversations/{conversation_id}/messages/`
  Future<List<AdminChatMessage>> getAdminConversationMessages(
    String conversationId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.conversationMessages(conversationId),
      );
      final data = response.data;
      final list = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List<dynamic>
          : (data is List ? data : <dynamic>[]);
      final remote = list
          .whereType<Map<String, dynamic>>()
          .map(AdminChatMessage.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        return remote;
      }
    } catch (_) {}
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    return idx != -1 ? _conversations[idx].messages : const [];
  }

  /// Section 8.10: `POST /api/v1/conversations/{conversation_id}/messages/`
  Future<AdminConversation> sendAdminConversationMessage(
    String conversationId, {
    required String body,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.conversationMessages(conversationId),
        data: {
          'message_type': messageType,
          'body': body,
          if (attachmentUrl != null && attachmentUrl.isNotEmpty)
            'attachment_url': attachmentUrl,
        },
      );
    } catch (_) {}

    final now = DateTime.now();
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final current = _conversations[idx];
      final newMsg = AdminChatMessage(
        id: 'cmsg-${now.millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: 'admin-uuid-001',
        senderName: '${current.storeName} Admin',
        senderRole: 'admin',
        messageType: messageType,
        body: body,
        attachmentUrl: attachmentUrl,
        isRead: true,
        readAt: now,
        createdAt: now,
      );
      final updatedMessages =
          current.messages
              .map((m) => m.isRead ? m : m.copyWith(isRead: true, readAt: now))
              .toList()
            ..add(newMsg);
      _conversations[idx] = current.copyWith(
        updatedAt: now,
        messages: updatedMessages,
      );
      return _conversations[idx];
    }
    return _conversations.first;
  }

  /// Section 8.10: `POST /api/v1/messages/{message_id}/read/`
  Future<void> markAdminChatMessageRead(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _apiClient.post(ApiConstants.messageRead(messageId));
    } catch (_) {}
    final now = DateTime.now();
    final cIdx = _conversations.indexWhere((c) => c.id == conversationId);
    if (cIdx != -1) {
      final conv = _conversations[cIdx];
      final updatedMsgs = conv.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(isRead: true, readAt: now);
        }
        return m;
      }).toList();
      _conversations[cIdx] = conv.copyWith(messages: updatedMsgs);
    }
  }
}

extension _ProductMatchExt on AdminProduct {
  bool productIdMatches(String targetId) => id == targetId;
}
