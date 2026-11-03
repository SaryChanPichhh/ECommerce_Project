import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Dedicated "Customer Order Approvals, Product Approvals & Reviews Moderation"
/// Control Dashboard following `lib/docs/order_process.md` (Steps 1–17) +
/// Section 9.3 Product Status Approval + Section 9.7 Reviews Moderation.
class AdminApprovedProductsView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminApprovedProductsView({
    super.key,
    required this.controller,
  });

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Just now';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pendingOrderCount = controller.awaitingApprovalOrdersCount;
      final confirmedOrderCount = controller.confirmedReadyOrdersCount;
      final approvedProdCount = controller.approvedProductsCount;
      final pendingProdCount = controller.pendingApprovalProductsCount;
      final subTab = controller.approvalSubTabIndex.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary 2x2 Mobile KPI Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildApprovalKpiCard(
                      title: 'Orders Awaiting Approval',
                      value: '$pendingOrderCount',
                      subtitle: 'Step 7–9 Pending orders',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFD97706),
                      onTap: () {
                        controller.approvalSubTabIndex.value = 0;
                        controller.orderApprovalFilter.value = 'pending';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildApprovalKpiCard(
                      title: 'Approved Orders',
                      value: '$confirmedOrderCount',
                      subtitle: 'Ready for Step 10 prep',
                      icon: Icons.task_alt_rounded,
                      color: const Color(0xFF16A34A),
                      onTap: () {
                        controller.approvalSubTabIndex.value = 0;
                        controller.orderApprovalFilter.value = 'confirmed';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildApprovalKpiCard(
                      title: 'Product Approvals',
                      value: '$approvedProdCount / ${controller.products.length}',
                      subtitle: '$pendingProdCount pending review',
                      icon: Icons.verified_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        controller.approvalSubTabIndex.value = 1;
                        controller.approvalFilter.value = 'all';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildApprovalKpiCard(
                      title: 'Reviews Queue',
                      value: '${controller.reviews.length}',
                      subtitle: 'Customer reviews',
                      icon: Icons.rate_review_outlined,
                      color: const Color(0xFF7C3AED),
                      onTap: () {
                        controller.approvalSubTabIndex.value = 2;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live Customer Order Sync & Simulation Banner (Follows `lib/docs/order_process.md`)
          _buildLiveSyncControlBanner(context, pendingOrderCount),
          const SizedBox(height: 16),

          // Sub-Tab Switcher: Customer Order Approvals | Product Approval Queue | Reviews Moderation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'Customer Order Approvals (${controller.orders.length})',
                        ),
                        selected: subTab == 0,
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: subTab == 0
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                        showCheckmark: false,
                        onSelected: (_) =>
                            controller.approvalSubTabIndex.value = 0,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          'Product Approvals (${controller.products.length})',
                        ),
                        selected: subTab == 1,
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: subTab == 1
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                        showCheckmark: false,
                        onSelected: (_) =>
                            controller.approvalSubTabIndex.value = 1,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          'Reviews (${controller.reviews.length})',
                        ),
                        selected: subTab == 2,
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: subTab == 2
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                        showCheckmark: false,
                        onSelected: (_) =>
                            controller.approvalSubTabIndex.value = 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (subTab == 0)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildOrderFilterChip('All Orders', 'all'),
                        const SizedBox(width: 6),
                        _buildOrderFilterChip(
                          'Pending Approval ($pendingOrderCount)',
                          'pending',
                        ),
                        const SizedBox(width: 6),
                        _buildOrderFilterChip(
                          'Confirmed ($confirmedOrderCount)',
                          'confirmed',
                        ),
                        const SizedBox(width: 6),
                        _buildOrderFilterChip('Processing', 'processing'),
                        const SizedBox(width: 6),
                        _buildOrderFilterChip('Cancelled / Failed', 'cancelled'),
                      ],
                    ),
                  )
                else if (subTab == 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 6),
                        _buildFilterChip('Pending Approval', 'draft'),
                        const SizedBox(width: 6),
                        _buildFilterChip('Approved (Live)', 'active'),
                        const SizedBox(width: 6),
                        _buildFilterChip('Rejected / Archived', 'archived'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (subTab == 0)
            _buildCustomerOrderApprovalsSection(context)
          else if (subTab == 1)
            _buildProductApprovalGrid()
          else
            _buildReviewsModerationCard(),
        ],
      );
    });
  }

  Widget _buildLiveSyncControlBanner(
    BuildContext context,
    int pendingOrderCount,
  ) {
    final autoSync = controller.isAutoSyncEnabled.value;
    final syncTime = _formatTime(controller.lastSyncedAt.value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFF38BDF8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Order Approval & Live Sync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Steps 1–9 of order_process.md • Last synced: $syncTime',
                      style: const TextStyle(
                        color: Color(0xFFBAE6FD),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: controller.toggleAutoSync,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: autoSync
                        ? const Color(0xFF16A34A).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: autoSync
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        autoSync ? Icons.bolt_rounded : Icons.pause_rounded,
                        size: 13,
                        color: autoSync
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        autoSync ? 'Auto-Sync ON' : 'Paused',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: autoSync
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isPerformingAction.value
                    ? null
                    : () => _showSimulateCustomerOrderModal(context),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                label: const Text('New Customer Order (Steps 1–8)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (pendingOrderCount > 0)
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : controller.approveAllPendingCustomerOrders,
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: Text('Approve All Pending ($pendingOrderCount)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: controller.isPerformingAction.value
                    ? null
                    : () => controller.syncCustomerOrdersNow(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Sync Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Sub-Tab 0: Customer Order Approvals & Sync Queue (order_process.md)
  // ──────────────────────────────────────────────────────────
  Widget _buildCustomerOrderApprovalsSection(BuildContext context) {
    final items = controller.filteredApprovalOrders;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Order Approval Queue',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'When a customer places an order (Step 6–7), approve to confirm payment (Step 8–9) & start preparing (Step 10)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sync Customer Orders',
                onPressed: () => controller.syncCustomerOrdersNow(),
                icon: const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 36,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No customer orders in this filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "New Customer Order (Steps 1–8)" above to place and sync a customer order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ...items.map(
              (ord) => _buildCustomerOrderApprovalCard(context, ord),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerOrderApprovalCard(
    BuildContext context,
    OrderModel order,
  ) {
    final s = order.status.toLowerCase();
    final isPending = s == OrderStatus.pending;
    final isConfirmed = s == OrderStatus.confirmed;
    final isProcessing = s == OrderStatus.processing;
    final isCancelledOrFailed =
        s == OrderStatus.cancelled || s == OrderStatus.failed;

    final payStatus = order.payment?.status.toLowerCase() ??
        (isPending ? PaymentStatus.pending : PaymentStatus.succeeded);
    final lineItems = order.items ?? const <OrderItem>[];
    final lastHistory =
        (order.statusHistory != null && order.statusHistory!.isNotEmpty)
        ? order.statusHistory!.last
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFFBEB)
            : (isConfirmed
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFDE68A)
              : (isConfirmed
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFE2E8F0)),
          width: isPending ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Order Number + Status Badge + Payment Badge + Total
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => controller.openOrderDetail(order),
                    child: Text(
                      order.orderNumber ?? order.id,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildOrderApprovalBadge(order.status),
                  const SizedBox(width: 6),
                  _buildPaymentBadge(payStatus),
                ],
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Customer + Store + Timestamp
          Text(
            'Customer: ${order.customerName ?? "Sok Dara"} (${order.customerPhone ?? "+855 96 123 4567"})',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Store: ${order.storeName ?? "Kutuku Official"} • Placed: ${_formatDateTime(order.createdAt)}',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),

          // Line Items & Stock Sync Summary
          if (lineItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...lineItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${item.productName ?? "Product"} (${item.variantName ?? "Standard"}) × ${item.quantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isCancelledOrFailed
                            ? Icons.restore_rounded
                            : Icons.inventory_2_outlined,
                        size: 13,
                        color: isCancelledOrFailed
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          isCancelledOrFailed
                              ? 'Stock Sync: Variant stock restored & payment refunded/failed'
                              : 'Stock Sync: Reserved ${order.itemCount ?? lineItems.length} unit(s) from ProductVariant.stock_quantity (Step 6)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCancelledOrFailed
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (lastHistory?.note != null && lastHistory!.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Latest Audit: ${lastHistory.note}',
              style: const TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF475569),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Buttons (Steps 9, 10, 11 & Cancel/Restore Stock)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isPending) ...[
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.approveCustomerOrder(
                            order.id,
                            autoStartPreparing: false,
                          ),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve & Confirm (Step 9)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 35),
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.approveCustomerOrder(
                            order.id,
                            autoStartPreparing: true,
                          ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 17),
                  label: const Text('Approve & Prepare (Steps 9–10)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 35),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (isConfirmed)
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.startPreparingOrder(order.id),
                  icon: const Icon(Icons.play_arrow_rounded, size: 17),
                  label: const Text('Start Preparing (Step 10)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 35),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isProcessing)
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () async {
                          final shipment = await controller
                              .createShipmentForOrder(order.id);
                          controller.openShipmentDetail(shipment);
                        },
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Create Shipment (Step 11)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 35),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => controller.openOrderDetail(order),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text('Order Workspace'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 35),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isPending || isConfirmed || isProcessing)
                OutlinedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.cancelOrFailOrder(
                            order.id,
                            isCancel: true,
                            note:
                                'Order rejected/cancelled by Admin — variant stock restored',
                          ),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 15,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Reject & Restore Stock',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 35),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderApprovalBadge(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    String text;

    switch (s) {
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        text = '⏳ Pending Approval';
        break;
      case OrderStatus.confirmed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        text = '✓ Confirmed';
        break;
      case OrderStatus.processing:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        text = '⚙ Processing';
        break;
      case OrderStatus.shipped:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        text = '🚚 Shipped';
        break;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        text = '✓ Delivered';
        break;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        text = '✕ ${s.toUpperCase()}';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String payStatus) {
    final p = payStatus.toLowerCase();
    final isPaid = p == PaymentStatus.succeeded;
    final isRefunded = p == PaymentStatus.refunded;
    final isFailed = p == PaymentStatus.failed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFDCFCE7)
            : (isRefunded || isFailed
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Pay: ${payStatus.toUpperCase()}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPaid
              ? const Color(0xFF15803D)
              : (isRefunded || isFailed
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Future<void> _showSimulateCustomerOrderModal(BuildContext context) async {
    final customerNameCtrl = TextEditingController(text: 'Sok Dara');
    final customerPhoneCtrl = TextEditingController(text: '+855 96 123 4567');
    final addressCtrl = TextEditingController(
      text: 'No. 168 Russian Federation Blvd (110), Toul Kork, Phnom Penh',
    );
    final qtyCtrl = TextEditingController(text: '1');
    final products = controller.products;
    String selectedProductId = products.isNotEmpty ? products.first.id : '';
    bool autoPayAndConfirm = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Color(0xFF2563EB),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Place & Sync Customer Order',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Executes Steps 1–8 of lib/docs/order_process.md',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (products.isNotEmpty) ...[
                        const Text(
                          'Product & Variant (Step 1)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedProductId,
                          isExpanded: true,
                          items: products.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                '${p.name} (\$${p.basePrice.toStringAsFixed(2)} • ${p.totalStock} in stock)',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => selectedProductId = v);
                            }
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: customerNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: customerPhoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Customer Phone',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Shipping Address (Step 4)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: autoPayAndConfirm,
                        onChanged: (val) =>
                            setState(() => autoPayAndConfirm = val),
                        title: const Text(
                          'Auto-complete payment (Step 8–9 → Confirmed)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Keep OFF to place order as Pending so Admin can approve it manually',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final qty =
                                  (int.tryParse(qtyCtrl.text.trim()) ?? 1)
                                      .clamp(1, 99);
                              Navigator.of(dialogContext).pop();
                              await controller.simulateCustomerOrder(
                                productId: selectedProductId,
                                quantity: qty,
                                customerName: customerNameCtrl.text.trim(),
                                customerPhone: customerPhoneCtrl.text.trim(),
                                shippingAddressText: addressCtrl.text.trim(),
                                autoPayAndConfirm: autoPayAndConfirm,
                              );
                            },
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(
                              autoPayAndConfirm
                                  ? 'Place & Confirm'
                                  : 'Place Order (Pending Approval)',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderFilterChip(String label, String val) {
    final selected = controller.orderApprovalFilter.value == val;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFFDBEAFE),
      backgroundColor: const Color(0xFFF8FAFC),
      onSelected: (_) => controller.orderApprovalFilter.value = val,
    );
  }

  Widget _buildApprovalKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String val) {
    final selected = controller.approvalFilter.value == val;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFFDBEAFE),
      backgroundColor: const Color(0xFFF8FAFC),
      onSelected: (_) => controller.approvalFilter.value = val,
    );
  }

  Widget _buildProductApprovalGrid() {
    final items = controller.filteredApprovalProducts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Approval Queue',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Approve merchant products to publish live or archive unverified listings',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          ...items.map(_buildApprovalRowCard),
        ],
      ),
    );
  }

  Widget _buildApprovalRowCard(AdminProduct prod) {
    final isApproved = prod.isApproved;
    final isPending = prod.isPendingApproval;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFDE68A)
              : (isApproved
                  ? const Color(0xFFBBF7D0)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 54,
                  height: 54,
                  color: Colors.white,
                  child: prod.imageUrl != null && prod.imageUrl!.isNotEmpty
                      ? Image.network(
                          prod.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.inventory_2_outlined),
                        )
                      : const Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          prod.name,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        _buildStatusBadge(prod),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prod.storeName} • ${prod.categoryName} • SKU: ${prod.sku}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${prod.basePrice.toStringAsFixed(2)} • ${prod.totalStock} in stock',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isApproved)
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.updateProductApprovalStatus(prod, 'active'),
                  icon: const Icon(Icons.verified_outlined, size: 15),
                  label: const Text('Approve & Publish'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (!isPending)
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.updateProductApprovalStatus(prod, 'draft'),
                  icon: const Icon(Icons.pause_circle_outline, size: 15),
                  label: const Text('Move to Pending'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!prod.isArchived)
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.updateProductApprovalStatus(prod, 'archived'),
                  icon: const Icon(
                    Icons.block_flipped,
                    size: 15,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AdminProduct prod) {
    if (prod.isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          '✓ Approved',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF15803D),
          ),
        ),
      );
    }
    if (prod.isPendingApproval) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          '⏳ Pending',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB45309),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Archived',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFFB91C1C),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Sub-Tab 2: Section 9.7 Customer Reviews Moderation
  // ──────────────────────────────────────────────────────────
  Widget _buildReviewsModerationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews Moderation',
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...controller.reviews.map((rev) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        rev.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '★' * rev.rating,
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 13.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          rev.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${rev.comment}" — by ${rev.customerName}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.moderateReviewStatus(
                          rev.id,
                          'published',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'Publish',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.moderateReviewStatus(
                          rev.id,
                          'hidden',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'Hide',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFDC2626),
                          size: 19,
                        ),
                        onPressed: () => controller.deleteReview(rev.id),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
