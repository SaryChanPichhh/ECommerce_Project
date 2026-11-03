import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../domain/entities/admin_models.dart';

class AdminDashboardController extends GetxController {
  late final AdminRemoteDataSource _dataSource;

  AdminDashboardController({AdminRemoteDataSource? dataSource}) {
    _dataSource = dataSource ??
        AdminRemoteDataSource(
          apiClient: Get.find<ApiClient>(),
          localStorage: Get.find<LocalStorage>(),
        );
  }

  // ──────────────────────────────────────────────────────────
  // Navigation & Sub-View State
  // ──────────────────────────────────────────────────────────
  /// Sidebar sections:
  /// 0: Dashboard
  /// 1: Orders
  /// 2: Shipments
  /// 3: Products (Catalog, Variants, Categories, Stores, Tags)
  /// 4: Approved Products (Approval Queue + Reviews Moderation)
  /// 5: Customers (Users & Customers Control Management)
  /// 6: Reports (Analytics, Support Tickets, Notifications, Legal Docs)
  /// 7: Settings
  final RxInt selectedNavIndex = 0.obs;

  // Orders View State
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();
  final RxBool showOrderListTable = false.obs;
  final RxString orderStatusFilter = 'all'.obs;
  final RxString orderSearchQuery = ''.obs;
  final RxInt orderDetailTabIndex = 0.obs; // 0: Items, 1: Address, 2: Payment, 3: Status History

  // Shipments View State
  final RxList<OrderShipmentModel> shipments = <OrderShipmentModel>[].obs;
  final Rxn<OrderShipmentModel> selectedShipment = Rxn<OrderShipmentModel>();
  final RxBool showShipmentListTable = false.obs;
  final RxString shipmentStatusFilter = 'all'.obs;
  final RxBool isHandoffFormOpen = false.obs;
  final RxInt shipmentTrackingTabIndex = 0.obs; // 0: Tracking Events, 1: Details
  final RxList<String> recentStatusBanners = <String>[].obs;

  // Products & Catalog State
  final RxList<AdminProduct> products = <AdminProduct>[].obs;
  final RxList<AdminCategory> categories = <AdminCategory>[].obs;
  final RxList<AdminStore> stores = <AdminStore>[].obs;
  final RxList<AdminTag> tags = <AdminTag>[].obs;
  final RxInt productSectionTabIndex = 0.obs; // 0: Products, 1: Categories, 2: Stores, 3: Tags
  final RxString productSearchQuery = ''.obs;
  final RxString productStatusFilter = 'all'.obs;
  final RxString productCategoryFilter = 'all'.obs;
  final RxString categorySlugSearchQuery = ''.obs;
  final Rxn<AdminCategory> searchedCategory = Rxn<AdminCategory>();
  final RxString storeSlugSearchQuery = ''.obs;
  final Rxn<AdminStore> searchedStore = Rxn<AdminStore>();

  // Approved Products, Customer Order Approvals & Reviews Moderation State
  final RxString approvalFilter = 'all'.obs; // 'all', 'draft' (pending), 'active' (approved), 'archived'
  final RxInt approvalSubTabIndex = 0.obs; // 0: Customer Order Approvals, 1: Product Approval Queue, 2: Customer Reviews Moderation
  final RxString orderApprovalFilter = 'all'.obs; // 'all', 'pending', 'confirmed', 'processing', 'cancelled'
  final Rx<DateTime> lastSyncedAt = DateTime.now().obs;
  final RxBool isAutoSyncEnabled = true.obs;
  Timer? _autoSyncTimer;
  final RxList<AdminReview> reviews = <AdminReview>[].obs;
  final RxString reviewStatusFilter = 'all'.obs; // 'all', 'published', 'hidden', 'flagged'

  // Users & Customers State
  final RxList<AdminUserCustomer> users = <AdminUserCustomer>[].obs;
  final RxString userSearchQuery = ''.obs;
  final RxString userRoleFilter = 'all'.obs; // 'all', 'customer', 'admin', 'support'
  final RxString userStatusFilter = 'all'.obs; // 'all', 'active', 'blocked', 'inactive'

  // Reports, Support Tickets, Notifications, Legal Governance & Conversations State
  final RxInt reportsSubTabIndex = 0.obs; // 0: Analytics, 1: Support Tickets, 2: Notifications, 3: Legal Docs, 4: Conversations
  final RxList<AdminSupportTicket> tickets = <AdminSupportTicket>[].obs;
  final Rxn<AdminSupportTicket> selectedTicket = Rxn<AdminSupportTicket>();
  final RxString ticketStatusFilter = 'all'.obs;
  final RxString ticketPriorityFilter = 'all'.obs;
  final RxList<AdminBroadcastNotification> notifications =
      <AdminBroadcastNotification>[].obs;
  final RxString notificationTypeFilter = 'all'.obs;
  final RxInt unreadNotificationsCount = 0.obs;
  final RxList<AdminLegalDocument> legalDocs = <AdminLegalDocument>[].obs;
  final RxString legalDocTypeFilter = 'all'.obs;
  final RxList<AdminConversation> conversations = <AdminConversation>[].obs;
  final Rxn<AdminConversation> selectedConversation = Rxn<AdminConversation>();

  // Loading & Admin Auth Session State
  final RxBool isLoading = false.obs;
  final RxBool isPerformingAction = false.obs;
  final RxString adminName = 'SETEC Admin'.obs;
  final RxString adminEmail = 'admin@example.com'.obs;
  final RxString adminPhone = '+855 12 000 001'.obs;
  final RxString adminRole = 'admin'.obs;
  final RxList<AdminDeviceSession> deviceSessions = <AdminDeviceSession>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initAdminSessionAndLoadAll();
    _startPeriodicOrderSync();
  }

  @override
  void onClose() {
    _autoSyncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicOrderSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (isAutoSyncEnabled.value &&
          !isLoading.value &&
          !isPerformingAction.value) {
        syncCustomerOrdersNow(silent: true);
      }
    });
  }

  void toggleAutoSync() {
    isAutoSyncEnabled.value = !isAutoSyncEnabled.value;
    Helpers.showSuccess(
      isAutoSyncEnabled.value
          ? 'Live customer order auto-sync enabled'
          : 'Live customer order auto-sync paused',
    );
  }

  Future<void> _initAdminSessionAndLoadAll() async {
    final localStorage = Get.isRegistered<LocalStorage>()
        ? Get.find<LocalStorage>()
        : LocalStorage();
    if (!localStorage.isAuthenticated()) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isLoading.value = true;
    try {
      var currentUser = UserSession.instance.currentUser;
      if (currentUser == null) {
        final savedUser = localStorage.getUserData();
        if (savedUser != null) {
          try {
            currentUser = UserModel.fromJson(savedUser);
            UserSession.instance.setSession(
              token: localStorage.getAccessToken() ?? '',
              user: currentUser,
            );
          } catch (_) {}
        }
      }
      if (currentUser != null) {
        adminName.value = currentUser.name;
        adminEmail.value = currentUser.email;
        adminRole.value = currentUser.role ?? 'admin';
      }
      await refreshAllData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAllData() async {
    final loadedOrders = await _dataSource.getAdminOrders();
    orders.assignAll(loadedOrders);

    final loadedShipments = await _dataSource.getAdminShipments();
    shipments.assignAll(loadedShipments);

    // Default selected order to ord-20261024-0001 (from lib/docs/img.png)
    if (selectedOrder.value == null && orders.isNotEmpty) {
      selectedOrder.value = orders.firstWhere(
        (o) => o.id == 'ord-20261024-0001',
        orElse: () => orders.first,
      );
    } else if (selectedOrder.value != null) {
      final refreshed = orders
          .where((o) => o.id == selectedOrder.value!.id)
          .toList();
      if (refreshed.isNotEmpty) {
        selectedOrder.value = refreshed.first;
      }
    }

    if (selectedShipment.value == null && shipments.isNotEmpty) {
      selectedShipment.value = shipments.first;
    } else if (selectedShipment.value != null) {
      final refreshed = shipments
          .where((s) => s.id == selectedShipment.value!.id)
          .toList();
      if (refreshed.isNotEmpty) {
        selectedShipment.value = refreshed.first;
      }
    }

    final loadedProducts = await _dataSource.getAdminProducts();
    products.assignAll(loadedProducts);

    final loadedCategories = await _dataSource.getAdminCategories();
    categories.assignAll(loadedCategories);

    final loadedStores = await _dataSource.getAdminStores();
    stores.assignAll(loadedStores);

    final loadedTags = await _dataSource.getAdminTags();
    tags.assignAll(loadedTags);

    final loadedUsers = await _dataSource.getUsersAndCustomers();
    users.assignAll(loadedUsers);

    final loadedReviews = await _dataSource.getAdminReviews();
    reviews.assignAll(loadedReviews);

    final loadedTickets = await _dataSource.getAdminSupportTickets();
    tickets.assignAll(loadedTickets);
    if (selectedTicket.value == null && tickets.isNotEmpty) {
      selectedTicket.value = tickets.first;
    }

    final loadedNotifications = await _dataSource.getAdminNotifications();
    notifications.assignAll(loadedNotifications);
    unreadNotificationsCount.value =
        await _dataSource.getUnreadNotificationsCount();

    final loadedLegal = await _dataSource.getAdminLegalDocuments();
    legalDocs.assignAll(loadedLegal);

    final loadedConversations = await _dataSource.getAdminConversations();
    conversations.assignAll(loadedConversations);
    if (selectedConversation.value == null && conversations.isNotEmpty) {
      selectedConversation.value = conversations.first;
    } else if (selectedConversation.value != null) {
      final refreshedConv = conversations
          .where((c) => c.id == selectedConversation.value!.id)
          .toList();
      if (refreshedConv.isNotEmpty) {
        selectedConversation.value = refreshedConv.first;
      }
    }

    final loadedSessions = await _dataSource.getAdminDeviceSessions();
    deviceSessions.assignAll(loadedSessions);
    lastSyncedAt.value = DateTime.now();
  }

  // ──────────────────────────────────────────────────────────
  // Navigation Helpers
  // ──────────────────────────────────────────────────────────
  void selectNav(int index) {
    selectedNavIndex.value = index;
    if (index == 1 && selectedOrder.value == null && orders.isNotEmpty) {
      selectedOrder.value = orders.first;
    }
    if (index == 2 && selectedShipment.value == null && shipments.isNotEmpty) {
      selectedShipment.value = shipments.first;
    }
  }

  void openOrderDetail(OrderModel order) {
    selectedOrder.value = order;
    showOrderListTable.value = false;
    orderDetailTabIndex.value = 0;
    selectedNavIndex.value = 1;
  }

  void openShipmentDetail(OrderShipmentModel shipment, {bool openHandoff = false}) {
    selectedShipment.value = shipment;
    showShipmentListTable.value = false;
    isHandoffFormOpen.value = openHandoff;
    recentStatusBanners.clear();
    selectedNavIndex.value = 2;
  }

  OrderModel? findOrderForShipment(OrderShipmentModel shipment) {
    if (shipment.orderId == null) return null;
    final match = orders.where(
      (o) => o.id == shipment.orderId || o.orderNumber == shipment.orderId,
    );
    return match.isNotEmpty ? match.first : null;
  }

  // ──────────────────────────────────────────────────────────
  // Computed Dashboard KPIs & Filtered Lists
  // ──────────────────────────────────────────────────────────
  double get totalRevenue => orders
      .where((o) =>
          o.status != OrderStatus.cancelled && o.status != OrderStatus.failed)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingOrdersCount => orders
      .where((o) =>
          o.status == OrderStatus.pending || o.status == OrderStatus.confirmed)
      .length;

  int get awaitingApprovalOrdersCount =>
      orders.where((o) => o.status.toLowerCase() == OrderStatus.pending).length;

  int get confirmedReadyOrdersCount => orders
      .where((o) => o.status.toLowerCase() == OrderStatus.confirmed)
      .length;

  List<OrderModel> get pendingCustomerOrders => orders
      .where((o) => o.status.toLowerCase() == OrderStatus.pending)
      .toList();

  List<OrderModel> get filteredApprovalOrders {
    final filter = orderApprovalFilter.value.toLowerCase();
    return orders.where((o) {
      final s = o.status.toLowerCase();
      if (filter == 'pending') return s == OrderStatus.pending;
      if (filter == 'confirmed') return s == OrderStatus.confirmed;
      if (filter == 'processing') return s == OrderStatus.processing;
      if (filter == 'cancelled') {
        return s == OrderStatus.cancelled || s == OrderStatus.failed;
      }
      return true;
    }).toList();
  }

  int get processingOrdersCount =>
      orders.where((o) => o.status == OrderStatus.processing).length;

  int get activeShipmentsCount => shipments
      .where((s) => s.status != ShipmentStatus.delivered)
      .length;

  int get approvedProductsCount =>
      products.where((p) => p.isApproved).length;

  int get pendingApprovalProductsCount =>
      products.where((p) => p.isPendingApproval).length;

  List<OrderModel> get filteredOrders {
    return orders.where((o) {
      if (orderStatusFilter.value != 'all' &&
          o.status.toLowerCase() != orderStatusFilter.value.toLowerCase()) {
        return false;
      }
      if (orderSearchQuery.value.isNotEmpty) {
        final q = orderSearchQuery.value.toLowerCase();
        final matchId = (o.orderNumber ?? o.id).toLowerCase().contains(q);
        final matchCust = (o.customerName ?? '').toLowerCase().contains(q);
        final matchStore = (o.storeName ?? '').toLowerCase().contains(q);
        if (!matchId && !matchCust && !matchStore) return false;
      }
      return true;
    }).toList();
  }

  List<OrderShipmentModel> get filteredShipments {
    return shipments.where((s) {
      if (shipmentStatusFilter.value != 'all' &&
          s.status.toLowerCase() != shipmentStatusFilter.value.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AdminProduct> get filteredProducts {
    return products.where((p) {
      if (productStatusFilter.value != 'all' &&
          p.status.toLowerCase() != productStatusFilter.value.toLowerCase()) {
        return false;
      }
      if (productCategoryFilter.value != 'all' &&
          p.categoryId != productCategoryFilter.value &&
          p.categoryName.toLowerCase() !=
              productCategoryFilter.value.toLowerCase()) {
        return false;
      }
      if (productSearchQuery.value.isNotEmpty) {
        final q = productSearchQuery.value.toLowerCase();
        final matchName = p.name.toLowerCase().contains(q);
        final matchSku = p.sku.toLowerCase().contains(q);
        final matchCat = p.categoryName.toLowerCase().contains(q);
        final matchStore = p.storeName.toLowerCase().contains(q);
        if (!matchName && !matchSku && !matchCat && !matchStore) return false;
      }
      return true;
    }).toList();
  }

  List<AdminProduct> get filteredApprovalProducts {
    return products.where((p) {
      if (approvalFilter.value == 'draft') return p.isPendingApproval;
      if (approvalFilter.value == 'active') return p.isApproved;
      if (approvalFilter.value == 'archived') return p.isArchived;
      return true;
    }).toList();
  }

  List<AdminReview> get filteredReviews {
    return reviews.where((r) {
      if (reviewStatusFilter.value != 'all' &&
          r.status.toLowerCase() != reviewStatusFilter.value.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AdminSupportTicket> get filteredTickets {
    return tickets.where((t) {
      if (ticketStatusFilter.value != 'all' &&
          t.status.toLowerCase() != ticketStatusFilter.value.toLowerCase()) {
        return false;
      }
      if (ticketPriorityFilter.value != 'all' &&
          t.priority.toLowerCase() != ticketPriorityFilter.value.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AdminBroadcastNotification> get filteredNotifications {
    return notifications.where((n) {
      if (notificationTypeFilter.value != 'all' &&
          n.type.toLowerCase() != notificationTypeFilter.value.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AdminLegalDocument> get filteredLegalDocs {
    return legalDocs.where((d) {
      if (legalDocTypeFilter.value != 'all' &&
          d.type.toLowerCase() != legalDocTypeFilter.value.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AdminUserCustomer> get filteredUsers {
    return users.where((u) {
      if (userRoleFilter.value != 'all' &&
          u.role.toLowerCase() != userRoleFilter.value.toLowerCase()) {
        return false;
      }
      if (userStatusFilter.value != 'all' &&
          u.status.toLowerCase() != userStatusFilter.value.toLowerCase()) {
        return false;
      }
      if (userSearchQuery.value.isNotEmpty) {
        final q = userSearchQuery.value.toLowerCase();
        if (!u.name.toLowerCase().contains(q) &&
            !u.email.toLowerCase().contains(q) &&
            !u.phone.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ──────────────────────────────────────────────────────────
  // Order & Shipment Fulfillment Actions (Steps 9 to 17 + Direct Overrides)
  // ──────────────────────────────────────────────────────────

  /// Section 9.5: Direct Admin Order Status Update (`PATCH /api/v1/admin/orders/{order_id}/status/`)
  Future<void> updateOrderStatusDirect(
    String orderId, {
    required String status,
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.updateAdminOrderStatus(
        orderId,
        status: status,
        note: note ?? 'Status updated to $status via admin override',
      );
      await _syncOrdersAndShipments(updatedOrderId: updated.id);
      Helpers.showSuccess('Order $orderId status updated to $status');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 9 (Manual Admin Confirm): `pending` -> `confirmed`
  Future<void> confirmOrderManually(String orderId, {String? note}) async {
    await approveCustomerOrder(orderId, note: note, autoStartPreparing: false);
  }

  /// Steps 8 & 9 (+ optional Step 10) of `lib/docs/order_process.md`:
  /// Approves a customer's `pending` order (`pending` -> `confirmed`, or `pending` -> `confirmed` -> `processing`
  /// when `autoStartPreparing == true`), syncs payment status to `succeeded`, and refreshes all views.
  Future<void> approveCustomerOrder(
    String orderId, {
    String? note,
    bool autoStartPreparing = false,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.approveCustomerOrder(
        orderId,
        note: note ??
            (autoStartPreparing
                ? 'Customer order approved & store started preparing products'
                : 'Customer order approved & payment confirmed by Admin'),
        autoStartPreparing: autoStartPreparing,
      );
      await _syncOrdersAndShipments(updatedOrderId: updated.id);
      Helpers.showSuccess(
        autoStartPreparing
            ? 'Order ${updated.orderNumber ?? updated.id} approved & moved to Processing (Steps 9–10)'
            : 'Order ${updated.orderNumber ?? updated.id} approved & Confirmed (Step 9)',
      );
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Batch-approves all `pending` customer orders in the queue (`pending` -> `confirmed`).
  Future<void> approveAllPendingCustomerOrders() async {
    final pendingList = List<OrderModel>.from(pendingCustomerOrders);
    if (pendingList.isEmpty) {
      Helpers.showSuccess('All customer orders are already approved!');
      return;
    }
    isPerformingAction.value = true;
    try {
      String? lastId;
      for (final ord in pendingList) {
        final updated = await _dataSource.approveCustomerOrder(
          ord.id,
          note: 'Batch-approved by Admin',
        );
        lastId = updated.id;
      }
      await _syncOrdersAndShipments(updatedOrderId: lastId);
      Helpers.showSuccess(
        'Approved ${pendingList.length} pending customer order(s) & synced!',
      );
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Steps 1–8 of `lib/docs/order_process.md`:
  /// Places/simulates an incoming customer order (Cart -> Address -> Checkout Preview -> Place Order + Deduct Stock -> Optional Payment)
  /// and synchronizes it into the Admin Approval Queue & Orders views.
  Future<OrderModel> simulateCustomerOrder({
    String? productId,
    String? variantId,
    int quantity = 1,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? shippingAddressText,
    bool autoPayAndConfirm = false,
  }) async {
    isPerformingAction.value = true;
    try {
      final created = await _dataSource.placeCustomerOrderAndSync(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        shippingAddressText: shippingAddressText,
        autoPayAndConfirm: autoPayAndConfirm,
      );
      await _syncOrdersAndShipments(updatedOrderId: created.id);
      Helpers.showSuccess(
        autoPayAndConfirm
            ? 'Customer order ${created.orderNumber ?? created.id} placed & auto-confirmed!'
            : 'New customer order ${created.orderNumber ?? created.id} synced (Pending Approval)!',
      );
      return created;
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Synchronizes customer orders, shipments, and product variant stock from the backend API.
  Future<void> syncCustomerOrdersNow({bool silent = false}) async {
    if (!silent) {
      isPerformingAction.value = true;
    }
    try {
      await _syncOrdersAndShipments();
      if (!silent) {
        Helpers.showSuccess(
          'Synced ${orders.length} orders ($awaitingApprovalOrdersCount pending approval)',
        );
      }
    } finally {
      if (!silent) {
        isPerformingAction.value = false;
      }
    }
  }

  /// Step 10: Store prepares the order (`Confirmed` -> `Processing`)
  Future<void> startPreparingOrder(String orderId, {String? note}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.startOrderPreparing(
        orderId,
        note: note ?? 'Store started preparing the products',
      );
      await _syncOrdersAndShipments(updatedOrderId: updated.id);
      Helpers.showSuccess('Step 10: Order is now Processing');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 11: Shipment is created (`Shipment` -> `Pending`)
  Future<OrderShipmentModel> createShipmentForOrder(
    String orderId, {
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final created = await _dataSource.createOrderShipment(
        orderId,
        note: note ?? 'Store started preparing the fulfillment',
      );
      await _syncOrdersAndShipments(
        updatedOrderId: orderId,
        updatedShipmentId: created.id,
      );
      Helpers.showSuccess('Step 11: Shipment ${created.id} created (Pending)');
      return created;
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Section 9.6: Direct Shipment Metadata/Status Update (`PATCH /api/v1/admin/shipments/{shipment_id}/`)
  Future<void> updateShipmentMetadata(
    String shipmentId, {
    String? trackingNumber,
    String? carrierName,
    String? status,
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.updateAdminShipment(
        shipmentId,
        trackingNumber: trackingNumber,
        carrierName: carrierName,
        status: status,
        note: note,
      );
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      Helpers.showSuccess('Shipment $shipmentId updated');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 12: Products are packed (`Shipment` -> `Packed`)
  Future<void> markShipmentAsPacked(
    String shipmentId, {
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.markShipmentPacked(
        shipmentId,
        note: note ?? 'Products packed and ready for pickup',
      );
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      recentStatusBanners.assignAll(['Shipment is now Packed']);
      Helpers.showSuccess('Step 12: Shipment is now Packed');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 13: Package is handed to the carrier (`Order` -> `Shipped`, `Shipment` -> `In Transit`)
  Future<void> handoffShipmentToCarrier(
    String shipmentId, {
    required String carrierName,
    required String trackingNumber,
    required String location,
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.handoffShipmentToCarrier(
        shipmentId,
        carrierName: carrierName,
        trackingNumber: trackingNumber,
        location: location,
        note: note,
      );
      isHandoffFormOpen.value = false;
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      recentStatusBanners.assignAll([
        'Shipment → In Transit',
        'Order → Shipped',
      ]);
      Helpers.showSuccess(
        'Step 13: Handed off to $carrierName ($trackingNumber)',
      );
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 14: Record carrier tracking event (`POST /api/v1/admin/shipments/{shipment_id}/events`)
  Future<void> addShipmentTrackingEvent(
    String shipmentId, {
    required String location,
    required String description,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.recordShipmentTrackingEvent(
        shipmentId,
        location: location,
        description: description,
      );
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      Helpers.showSuccess('Step 14: Tracking checkpoint recorded');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 15: Mark Out for Delivery (`Shipment` -> `Out for Delivery`)
  Future<void> markShipmentOutForDelivery(
    String shipmentId, {
    required String location,
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.markShipmentOutForDelivery(
        shipmentId,
        location: location,
        note: note ?? 'Courier is delivering the package',
      );
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      recentStatusBanners.assignAll(['Shipment → Out for Delivery']);
      Helpers.showSuccess('Step 15: Shipment marked Out for Delivery');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Step 16 & 17: Customer confirms receipt -> `Delivered`
  Future<void> confirmShipmentDelivery(
    String shipmentId, {
    String? note,
    String? confirmedBy,
  }) async {
    isPerformingAction.value = true;
    try {
      final updated = await _dataSource.confirmShipmentDelivery(
        shipmentId,
        note: note ?? 'Product received in good condition',
        confirmedBy: confirmedBy,
      );
      await _syncOrdersAndShipments(
        updatedOrderId: updated.orderId,
        updatedShipmentId: updated.id,
      );
      recentStatusBanners.assignAll([
        'Shipment → Delivered',
        'Order → Delivered',
      ]);
      Helpers.showSuccess('Steps 16 & 17: Delivery confirmed & Order Delivered!');
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Admin Cancel or Fail Order
  Future<void> cancelOrFailOrder(
    String orderId, {
    required bool isCancel,
    String? note,
  }) async {
    isPerformingAction.value = true;
    try {
      if (isCancel) {
        await _dataSource.cancelAdminOrder(orderId, note: note);
      } else {
        await _dataSource.failAdminOrder(orderId, note: note);
      }
      await _syncOrdersAndShipments(updatedOrderId: orderId);
      Helpers.showSuccess(
        isCancel ? 'Order cancelled & stock restored' : 'Order marked as failed',
      );
    } finally {
      isPerformingAction.value = false;
    }
  }

  /// Reset showcase order `ord-20261024-0001` back to Step 10 (`Confirmed`) so user can replay Steps 10-17 anytime!
  Future<void> resetDemoOrderFlow() async {
    final oct24_1020 = DateTime(2026, 10, 24, 10, 20);
    await _dataSource.updateAdminOrderStatus(
      'ord-20261024-0001',
      status: OrderStatus.confirmed,
      note: 'Reset to Step 10 (Confirmed) for interactive demo',
    );
    shipments.removeWhere((s) => s.orderId == 'ord-20261024-0001');
    final ordIdx = orders.indexWhere((o) => o.id == 'ord-20261024-0001');
    if (ordIdx != -1) {
      final o = orders[ordIdx];
      final resetOrd = OrderModel(
        id: o.id,
        orderNumber: o.orderNumber,
        customerId: o.customerId,
        customerName: o.customerName,
        customerPhone: o.customerPhone,
        customerEmail: o.customerEmail,
        storeId: o.storeId,
        storeName: o.storeName,
        shippingAddressId: o.shippingAddressId,
        shippingAddressText: o.shippingAddressText,
        subtotalAmount: o.subtotalAmount,
        totalAmount: o.totalAmount,
        currency: o.currency,
        status: OrderStatus.confirmed,
        itemCount: o.itemCount,
        items: o.items,
        payment: o.payment,
        shipments: const [],
        statusHistory: [
          OrderStatusHistoryModel(
            id: 'sh-reset-1',
            fromStatus: OrderStatus.pending,
            toStatus: OrderStatus.confirmed,
            note: 'Payment succeeded via internal payment service',
            createdAt: oct24_1020,
          ),
        ],
        createdAt: oct24_1020,
        updatedAt: DateTime.now(),
      );
      orders[ordIdx] = resetOrd;
      selectedOrder.value = resetOrd;
    }
    selectedNavIndex.value = 1;
    showOrderListTable.value = false;
    Helpers.showSuccess('Reset ord-20261024-0001 to Step 10 (Confirmed)');
  }

  Future<void> _syncOrdersAndShipments({
    String? updatedOrderId,
    String? updatedShipmentId,
  }) async {
    final loadedOrders = await _dataSource.getAdminOrders();
    orders.assignAll(loadedOrders);
    final loadedShipments = await _dataSource.getAdminShipments();
    shipments.assignAll(loadedShipments);
    final loadedProducts = await _dataSource.getAdminProducts();
    products.assignAll(loadedProducts);
    lastSyncedAt.value = DateTime.now();

    if (updatedOrderId != null) {
      final match = orders.where(
        (o) => o.id == updatedOrderId || o.orderNumber == updatedOrderId,
      );
      if (match.isNotEmpty) {
        selectedOrder.value = match.first;
      }
    } else if (selectedOrder.value != null) {
      final match = orders.where((o) => o.id == selectedOrder.value!.id);
      if (match.isNotEmpty) {
        selectedOrder.value = match.first;
      }
    }

    if (updatedShipmentId != null) {
      final match = shipments.where((s) => s.id == updatedShipmentId);
      if (match.isNotEmpty) {
        selectedShipment.value = match.first;
      }
    } else if (selectedShipment.value != null) {
      final match = shipments.where((s) => s.id == selectedShipment.value!.id);
      if (match.isNotEmpty) {
        selectedShipment.value = match.first;
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // Product, Approval, Variant & Variant Option Control Actions (Section 9.3)
  // ──────────────────────────────────────────────────────────
  Future<void> saveProduct(
    AdminProduct product, {
    required bool isNew,
    bool usePut = false,
  }) async {
    if (isNew) {
      final created = await _dataSource.createAdminProduct(product);
      productStatusFilter.value = 'all';
      Helpers.showSuccess('Product "${created.name}" created (${created.sku})');
    } else {
      final updated =
          await _dataSource.updateAdminProduct(product, usePut: usePut);
      Helpers.showSuccess('Product "${updated.name}" updated');
    }
    final refreshed = await _dataSource.getAdminProducts();
    products.assignAll(refreshed);
  }

  Future<void> updateProductApprovalStatus(
    AdminProduct product,
    String newStatus,
  ) async {
    final updated = product.copyWith(status: newStatus);
    await _dataSource.updateAdminProduct(updated);
    products.assignAll(await _dataSource.getAdminProducts());
    final label = newStatus == 'active'
        ? 'Approved & Published'
        : (newStatus == 'draft' ? 'Moved to Pending Queue' : 'Archived');
    Helpers.showSuccess('${product.name}: $label');
  }

  Future<void> deleteProduct(String productId) async {
    await _dataSource.deleteAdminProduct(productId);
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Product removed from catalog');
  }

  Future<void> addVariantToProduct(AdminProductVariant variant) async {
    await _dataSource.createAdminVariant(variant);
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Variant "${variant.name}" added');
  }

  /// Section 9.3: `PUT` / `PATCH /api/v1/admin/product/variants/{variant_id}/`
  Future<void> updateVariantOnProduct(
    AdminProductVariant variant, {
    bool usePut = false,
  }) async {
    await _dataSource.updateAdminVariant(variant, usePut: usePut);
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Variant "${variant.name}" updated');
  }

  Future<void> removeVariantFromProduct(
    String productId,
    String variantId,
  ) async {
    await _dataSource.deleteAdminVariant(productId, variantId);
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Variant deleted');
  }

  /// Section 9.3: `POST /api/v1/admin/product/variant-options/`
  Future<void> addVariantOption({
    required String productId,
    required String variantId,
    required String name,
    required String value,
  }) async {
    await _dataSource.createAdminVariantOption(
      productId: productId,
      variantId: variantId,
      name: name,
      value: value,
    );
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Option $name: $value added');
  }

  /// Section 9.3: `PUT` / `PATCH /api/v1/admin/product/variant-options/{option_id}/`
  Future<void> updateVariantOption({
    required String productId,
    required String variantId,
    required AdminVariantOption option,
    bool usePut = false,
  }) async {
    await _dataSource.updateAdminVariantOption(
      productId: productId,
      variantId: variantId,
      option: option,
      usePut: usePut,
    );
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Option ${option.name}: ${option.value} updated');
  }

  /// Section 9.3: `DELETE /api/v1/admin/product/variant-options/{option_id}/`
  Future<void> deleteVariantOption({
    required String productId,
    required String variantId,
    required String optionId,
  }) async {
    await _dataSource.deleteAdminVariantOption(
      productId: productId,
      variantId: variantId,
      optionId: optionId,
    );
    products.assignAll(await _dataSource.getAdminProducts());
    Helpers.showSuccess('Variant attribute option removed');
  }

  // ──────────────────────────────────────────────────────────
  // Categories, Stores & Tags Actions (Sections 9.1, 9.2, 9.4)
  // ──────────────────────────────────────────────────────────
  Future<void> saveCategory(
    AdminCategory category, {
    bool usePut = false,
  }) async {
    await _dataSource.saveAdminCategory(category, usePut: usePut);
    categories.assignAll(await _dataSource.getAdminCategories());
    Helpers.showSuccess('Category "${category.name}" saved');
  }

  Future<void> toggleCategoryStatus(AdminCategory category) async {
    final nextStatus = category.status == 'active' ? 'inactive' : 'active';
    final updated = category.copyWith(status: nextStatus);
    await _dataSource.saveAdminCategory(updated, usePut: false);
    categories.assignAll(await _dataSource.getAdminCategories());
    Helpers.showSuccess('Category "${category.name}" is now $nextStatus');
  }

  /// Section 9.1: `GET /api/v1/admin/categories/search/?slug={slug}`
  Future<void> searchCategoryBySlug(String slug) async {
    categorySlugSearchQuery.value = slug.trim();
    if (slug.trim().isEmpty) {
      searchedCategory.value = null;
      return;
    }
    final result = await _dataSource.searchAdminCategoryBySlug(slug.trim());
    searchedCategory.value = result;
    if (result != null) {
      Helpers.showSuccess('Found category "${result.name}" (${result.slug})');
    } else {
      Helpers.showError('No category found matching slug "$slug"');
    }
  }

  Future<void> deleteCategory(String id) async {
    await _dataSource.deleteAdminCategory(id);
    categories.assignAll(await _dataSource.getAdminCategories());
    if (searchedCategory.value?.id == id) {
      searchedCategory.value = null;
    }
    Helpers.showSuccess('Category deleted');
  }

  Future<void> saveStore(
    AdminStore store, {
    bool usePut = false,
  }) async {
    await _dataSource.saveAdminStore(store, usePut: usePut);
    stores.assignAll(await _dataSource.getAdminStores());
    Helpers.showSuccess('Store "${store.name}" saved');
  }

  Future<void> updateStoreStatus(AdminStore store, String newStatus) async {
    final updated = store.copyWith(status: newStatus);
    await _dataSource.saveAdminStore(updated, usePut: false);
    stores.assignAll(await _dataSource.getAdminStores());
    Helpers.showSuccess('Store "${store.name}" status set to $newStatus');
  }

  /// Section 9.2: `GET /api/v1/admin/stores/search/?slug={slug}`
  Future<void> searchStoreBySlug(String slug) async {
    storeSlugSearchQuery.value = slug.trim();
    if (slug.trim().isEmpty) {
      searchedStore.value = null;
      return;
    }
    final result = await _dataSource.searchAdminStoreBySlug(slug.trim());
    searchedStore.value = result;
    if (result != null) {
      Helpers.showSuccess('Found store "${result.name}" (${result.slug})');
    } else {
      Helpers.showError('No store found matching slug "$slug"');
    }
  }

  Future<void> deleteStore(String id) async {
    await _dataSource.deleteAdminStore(id);
    stores.assignAll(await _dataSource.getAdminStores());
    if (searchedStore.value?.id == id) {
      searchedStore.value = null;
    }
    Helpers.showSuccess('Store deleted');
  }

  Future<void> createTag(String name, String slug) async {
    await _dataSource.createAdminTag(name, slug);
    tags.assignAll(await _dataSource.getAdminTags());
    Helpers.showSuccess('Tag "$name" created');
  }

  /// Section 9.4: `PUT` / `PATCH /api/v1/admin/tags/{tag_id}/`
  Future<void> updateTag(
    AdminTag tag, {
    bool usePut = true,
  }) async {
    await _dataSource.updateAdminTag(tag, usePut: usePut);
    tags.assignAll(await _dataSource.getAdminTags());
    Helpers.showSuccess('Tag "${tag.name}" updated');
  }

  Future<void> deleteTag(String id) async {
    await _dataSource.deleteAdminTag(id);
    tags.assignAll(await _dataSource.getAdminTags());
    Helpers.showSuccess('Tag deleted');
  }

  // ──────────────────────────────────────────────────────────
  // Users & Customers Control Actions
  // ──────────────────────────────────────────────────────────
  Future<void> saveUserCustomer(
    AdminUserCustomer record, {
    String? password,
  }) async {
    await _dataSource.saveUserOrCustomer(record, password: password);
    users.assignAll(await _dataSource.getUsersAndCustomers());
    Helpers.showSuccess('User "${record.name}" saved');
  }

  Future<void> toggleUserStatus(AdminUserCustomer user) async {
    final nextStatus = user.status == 'active' ? 'blocked' : 'active';
    final updated = user.copyWith(status: nextStatus);
    await _dataSource.saveUserOrCustomer(updated);
    users.assignAll(await _dataSource.getUsersAndCustomers());
    Helpers.showSuccess(
      '${user.name} is now ${nextStatus.toUpperCase()}',
    );
  }

  Future<void> changeUserRole(AdminUserCustomer user, String newRole) async {
    final updated = user.copyWith(role: newRole);
    await _dataSource.saveUserOrCustomer(updated);
    users.assignAll(await _dataSource.getUsersAndCustomers());
    Helpers.showSuccess('${user.name} role updated to $newRole');
  }

  Future<void> deleteUserCustomer(String id) async {
    await _dataSource.deleteUserOrCustomer(id);
    users.assignAll(await _dataSource.getUsersAndCustomers());
    Helpers.showSuccess('User record deleted');
  }

  // ──────────────────────────────────────────────────────────
  // Reviews, Tickets, Notifications, Legal & Conversations Actions
  // ──────────────────────────────────────────────────────────
  Future<void> moderateReviewStatus(String reviewId, String status) async {
    await _dataSource.moderateReview(reviewId, status);
    reviews.assignAll(await _dataSource.getAdminReviews());
    Helpers.showSuccess('Review status updated to $status');
  }

  Future<void> deleteReview(String reviewId) async {
    await _dataSource.deleteReview(reviewId);
    reviews.assignAll(await _dataSource.getAdminReviews());
    Helpers.showSuccess('Review deleted');
  }

  Future<void> sendNotification({
    required String userId,
    required String targetLabel,
    required String type,
    required String title,
    required String body,
    String? actionUrl,
    Map<String, dynamic>? dataPayload,
  }) async {
    await _dataSource.sendBroadcastNotification(
      userId: userId,
      targetLabel: targetLabel,
      type: type,
      title: title,
      body: body,
      actionUrl: actionUrl,
      dataPayload: dataPayload,
    );
    notifications.assignAll(await _dataSource.getAdminNotifications());
    unreadNotificationsCount.value =
        await _dataSource.getUnreadNotificationsCount();
    Helpers.showSuccess('Notification dispatched to $targetLabel');
  }

  /// Section 8.11: Mark single notification read (`POST /api/v1/notifications/{id}/read/`)
  Future<void> markNotificationRead(String notificationId) async {
    await _dataSource.markNotificationRead(notificationId);
    notifications.assignAll(await _dataSource.getAdminNotifications());
    unreadNotificationsCount.value =
        await _dataSource.getUnreadNotificationsCount();
  }

  /// Section 8.11: Mark all notifications read (`POST /api/v1/notifications/read-all/`)
  Future<void> markAllNotificationsRead() async {
    await _dataSource.markAllNotificationsRead();
    notifications.assignAll(await _dataSource.getAdminNotifications());
    unreadNotificationsCount.value =
        await _dataSource.getUnreadNotificationsCount();
    Helpers.showSuccess('All notifications marked as read');
  }

  /// Section 8.11: Delete notification (`DELETE /api/v1/notifications/{id}/`)
  Future<void> deleteNotification(String notificationId) async {
    await _dataSource.deleteNotification(notificationId);
    notifications.assignAll(await _dataSource.getAdminNotifications());
    unreadNotificationsCount.value =
        await _dataSource.getUnreadNotificationsCount();
    Helpers.showSuccess('Notification deleted');
  }

  Future<void> updateTicket(
    String ticketId, {
    String? status,
    String? priority,
    String? assignedTo,
  }) async {
    final updated = await _dataSource.updateSupportTicket(
      ticketId,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
    );
    tickets.assignAll(await _dataSource.getAdminSupportTickets());
    selectedTicket.value = updated;
    Helpers.showSuccess('Ticket updated');
  }

  Future<void> replyToTicket(String ticketId, String message) async {
    if (message.trim().isEmpty) return;
    final updated =
        await _dataSource.replySupportTicket(ticketId, message.trim());
    tickets.assignAll(await _dataSource.getAdminSupportTickets());
    selectedTicket.value = updated;
    Helpers.showSuccess('Admin reply posted');
  }

  Future<void> saveLegalDocument(
    AdminLegalDocument doc, {
    bool usePatch = false,
  }) async {
    await _dataSource.saveAdminLegalDocument(doc, usePatch: usePatch);
    legalDocs.assignAll(await _dataSource.getAdminLegalDocuments());
    Helpers.showSuccess('Legal document "${doc.title}" saved');
  }

  Future<void> toggleLegalDocumentStatus(AdminLegalDocument doc) async {
    final nextStatus = doc.status == 'published' ? 'draft' : 'published';
    final updated = doc.copyWith(status: nextStatus);
    await _dataSource.saveAdminLegalDocument(updated, usePatch: true);
    legalDocs.assignAll(await _dataSource.getAdminLegalDocuments());
    Helpers.showSuccess('Legal document "${doc.title}" marked $nextStatus');
  }

  Future<void> deleteLegalDocument(String id) async {
    await _dataSource.deleteAdminLegalDocument(id);
    legalDocs.assignAll(await _dataSource.getAdminLegalDocuments());
    Helpers.showSuccess('Legal document deleted');
  }

  // ──────────────────────────────────────────────────────────
  // Customer-Store Conversations Actions (Section 8.10)
  // ──────────────────────────────────────────────────────────
  Future<void> sendConversationReply(
    String conversationId,
    String body, {
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    if (body.trim().isEmpty) return;
    final updated = await _dataSource.sendAdminConversationMessage(
      conversationId,
      body: body.trim(),
      messageType: messageType,
      attachmentUrl: attachmentUrl,
    );
    conversations.assignAll(await _dataSource.getAdminConversations());
    selectedConversation.value = updated;
    Helpers.showSuccess('Store reply sent');
  }

  Future<void> toggleConversationStatus(AdminConversation conversation) async {
    final nextStatus = conversation.status == 'open' ? 'closed' : 'open';
    final updated = await _dataSource.updateAdminConversationStatus(
      conversation.id,
      nextStatus,
    );
    conversations.assignAll(await _dataSource.getAdminConversations());
    selectedConversation.value = updated;
    Helpers.showSuccess('Conversation marked as $nextStatus');
  }

  Future<void> markChatMessageRead(
    String conversationId,
    String messageId,
  ) async {
    await _dataSource.markAdminChatMessageRead(conversationId, messageId);
    conversations.assignAll(await _dataSource.getAdminConversations());
    final match = conversations.where((c) => c.id == conversationId);
    if (match.isNotEmpty) {
      selectedConversation.value = match.first;
    }
  }

  // ──────────────────────────────────────────────────────────
  // Admin Auth Profile & Device Session Actions (Sections 8.1 & 8.2)
  // ──────────────────────────────────────────────────────────
  Future<void> updateAdminProfile({
    required String name,
    required String phone,
    String? avatarUrl,
  }) async {
    final updated = await _dataSource.updateAdminProfileMe(
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    adminName.value = updated.name;
    adminPhone.value = updated.phone ?? phone;
    Helpers.showSuccess('Admin profile updated via PATCH /api/v1/users/me/');
  }

  Future<void> refreshJwtToken() async {
    await _dataSource.refreshAdminToken();
    Helpers.showSuccess('JWT token rotated via POST /api/v1/auth/refresh/');
  }

  Future<void> logoutAdminSession() async {
    await _dataSource.logoutAdmin();
    Helpers.showSuccess('Session logged out via POST /api/v1/auth/logout/');
  }

  Future<void> revokeDeviceSession(String sessionId) async {
    await _dataSource.revokeAdminDeviceSession(sessionId);
    deviceSessions.assignAll(await _dataSource.getAdminDeviceSessions());
    Helpers.showSuccess('Device session revoked');
  }

  Future<void> switchSeedAccount({
    required String email,
    required String password,
    required String roleLabel,
  }) async {
    isLoading.value = true;
    try {
      await _dataSource.loginAsAdmin(email: email, password: password);
      adminEmail.value = email;
      adminRole.value = roleLabel;
      adminName.value = roleLabel == 'admin'
          ? 'SETEC System Admin'
          : (roleLabel == 'support' ? 'SETEC Support Agent' : 'Sarah Connor');
      await refreshAllData();
      Helpers.showSuccess('Authenticated as $email ($roleLabel)');
    } finally {
      isLoading.value = false;
    }
  }
}
