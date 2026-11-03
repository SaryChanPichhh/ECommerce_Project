import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Implements the Admin Orders & Fulfillment Management Web-UI matching
/// Panels 10 & 11 of `lib/docs/img.png` + full platform Orders table.
class AdminOrdersView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminOrdersView({
    super.key,
    required this.controller,
  });

  String _formatDateTime(DateTime? dt, {bool short = false}) {
    if (dt == null) return 'Oct 24, 2026 10:20';
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
    if (short) {
      return '$m ${dt.day}, $hh:$mm';
    }
    return '$m ${dt.day}, ${dt.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOrder = controller.selectedOrder.value ??
          (controller.orders.isNotEmpty ? controller.orders.first : null);
      final pendingCount = controller.awaitingApprovalOrdersCount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Order Switcher Bar + View All Orders Toggle
          _buildOrderSelectorBar(context, currentOrder),
          const SizedBox(height: 12),

          // Incoming Customer Orders Awaiting Approval Banner (Steps 7-9 of order_process.md)
          if (pendingCount > 0) ...[
            _buildPendingOrdersApprovalBanner(context, pendingCount),
            const SizedBox(height: 12),
          ],

          if (controller.showOrderListTable.value || currentOrder == null)
            _buildAllOrdersTableCard(context)
          else
            _buildOrderDetailFulfillmentWorkspace(context, currentOrder),
        ],
      );
    });
  }

  Widget _buildPendingOrdersApprovalBanner(
    BuildContext context,
    int pendingCount,
  ) {
    final pendingList = controller.pendingCustomerOrders;
    final firstPending = pendingList.isNotEmpty ? pendingList.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount Customer Order(s) Awaiting Admin Approval',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstPending != null
                          ? 'Latest: ${firstPending.orderNumber ?? firstPending.id} • ${firstPending.customerName ?? "Customer"} (\$${firstPending.totalAmount.toStringAsFixed(2)})'
                          : 'Approve pending orders to confirm payment (Step 9) & start preparing (Step 10)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (firstPending != null) ...[
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.approveCustomerOrder(
                            firstPending.id,
                            autoStartPreparing: false,
                          ),
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: Text(
                    'Approve ${firstPending.orderNumber ?? firstPending.id}',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isPerformingAction.value
                      ? null
                      : () => controller.approveCustomerOrder(
                            firstPending.id,
                            autoStartPreparing: true,
                          ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Approve & Start Preparing'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  controller.approvalSubTabIndex.value = 0;
                  controller.orderApprovalFilter.value = 'pending';
                  controller.selectNav(4);
                },
                icon: const Icon(Icons.fact_check_outlined, size: 15),
                label: const Text('Open Approval Queue'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSelectorBar(
    BuildContext context,
    OrderModel? currentOrder,
  ) {
    final isListMode = controller.showOrderListTable.value;
    final ordLabel = currentOrder?.orderNumber ?? currentOrder?.id ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          // Breadcrumb: Orders / ord-20261024-0001
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => controller.showOrderListTable.value = true,
                child: Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isListMode
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
              if (!isListMode && ordLabel.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '/',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  ordLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ],
          ),

          // Quick Order Selector Chips + Table Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Order:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                ...controller.orders.map((ord) {
                  final selected =
                      !isListMode && currentOrder?.id == ord.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        '${ord.orderNumber ?? ord.id} (${_statusDisplay(ord.status)})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                      selected: selected,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFF1F5F9),
                      showCheckmark: false,
                      onSelected: (_) => controller.openOrderDetail(ord),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () {
                    controller.showOrderListTable.value =
                        !controller.showOrderListTable.value;
                  },
                  icon: Icon(
                    isListMode
                        ? Icons.chrome_reader_mode_outlined
                        : Icons.table_chart_outlined,
                    size: 16,
                  ),
                  label: Text(
                    isListMode ? 'Fulfillment Detail View' : 'All Orders Table',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Panel 10 & Panel 11: Order Details & Order Fulfillment View
  // ──────────────────────────────────────────────────────────
  Widget _buildOrderDetailFulfillmentWorkspace(
    BuildContext context,
    OrderModel order,
  ) {
    final s = order.status.toLowerCase();
    final isConfirmed = s == OrderStatus.confirmed;
    final isProcessing = s == OrderStatus.processing;
    final isPending = s == OrderStatus.pending;

    final orderShipments = controller.shipments
        .where((sh) => sh.orderId == order.id)
        .toList();

    final stepBadgeNumber = isConfirmed ? '10' : (isProcessing ? '11' : '9');
    final stepBannerTitle = isConfirmed
        ? 'Store prepares the order  (Order → Processing)'
        : (isProcessing
            ? 'Shipment is created  (Shipment → Pending)'
            : 'Order Details & Fulfillment Status  (Order → ${_statusDisplay(order.status)})');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Context Header Pill (Matches "10 Store prepares the order" / "11 Shipment is created" in img.png)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stepBadgeNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stepBannerTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              if (s == OrderStatus.pending ||
                  s == OrderStatus.confirmed ||
                  s == OrderStatus.processing)
                TextButton.icon(
                  onPressed: () =>
                      _showCancelOrFailDialog(context, order, isCancel: true),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 15,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main White Order Details / Order Fulfillment Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title + Order ID + Status Badge + Primary Action Button
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProcessing ? 'Order Fulfillment' : 'Order Details',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            order.orderNumber ?? order.id,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          _buildOrderStatusPill(order.status),
                        ],
                      ),
                    ],
                  ),

                  // Primary Action Button on Right (Matches Panel 10 "▶ Start Preparing" & Panel 11 "+ Create Shipment")
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
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Approve & Confirm (Step 9)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
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
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('Approve & Prepare (Steps 9–10)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                          ),
                        ),
                      ],
                      if (isConfirmed)
                        ElevatedButton.icon(
                          onPressed: controller.isPerformingAction.value
                              ? null
                              : () => controller.startPreparingOrder(order.id),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text(
                            'Start Preparing',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      if (isProcessing && orderShipments.isEmpty)
                        ElevatedButton.icon(
                          onPressed: controller.isPerformingAction.value
                              ? null
                              : () => _showCreateShipmentModal(context, order),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Create Shipment',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      if (orderShipments.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => controller.openShipmentDetail(
                            orderShipments.first,
                          ),
                          icon: const Icon(
                            Icons.local_shipping_outlined,
                            size: 18,
                          ),
                          label: Text(
                            'Manage Shipment (${orderShipments.first.id}) →',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Responsive 2-Column Body:
              // Left (70%): Customer/Date/Total Summary + Shipments Box (when Processing) + Tabs (Items | Address | Payment | Status History)
              // Right (30%): Order Timeline + Shipments Card
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 780;
                  final leftContent = _buildOrderLeftContent(
                    context,
                    order,
                    orderShipments,
                    isProcessing: isProcessing,
                  );
                  final rightTimeline = _buildOrderRightTimeline(
                    context,
                    order,
                    orderShipments,
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: leftContent),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: rightTimeline),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftContent,
                      const SizedBox(height: 20),
                      rightTimeline,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderLeftContent(
    BuildContext context,
    OrderModel order,
    List<OrderShipmentModel> orderShipments, {
    required bool isProcessing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Summary Info Cards: Customer, Order Date, Total (Matches Panel 10 of img.png)
        LayoutBuilder(
          builder: (context, constraints) {
            final customerBox = _buildInfoBox(
              icon: Icons.person_outline_rounded,
              label: 'Customer',
              primaryText: order.customerName ?? 'Sok Dara',
              secondaryText: order.customerPhone ?? '+855 96 123 4567',
            );
            final dateBox = _buildInfoBox(
              icon: Icons.calendar_today_outlined,
              label: 'Order Date',
              primaryText: _formatDateTime(order.createdAt),
              secondaryText: 'Store: ${order.storeName ?? "Kutuku Official"}',
            );
            final totalBox = _buildInfoBox(
              icon: Icons.payments_outlined,
              label: 'Total',
              primaryText: '\$${order.totalAmount.toStringAsFixed(2)}',
              secondaryText:
                  '${order.items?.length ?? order.itemCount ?? 2} line items',
              isLargeValue: true,
            );

            if (constraints.maxWidth >= 560) {
              return Row(
                children: [
                  Expanded(flex: 4, child: customerBox),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: dateBox),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: totalBox),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: customerBox),
                    const SizedBox(width: 10),
                    Expanded(child: totalBox),
                  ],
                ),
                const SizedBox(height: 10),
                dateBox,
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Panel 11 "Shipments — No shipment yet / + Create Shipment" Card when order is Processing
        if (isProcessing && orderShipments.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 30,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No shipment yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create a shipment to start delivery.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateShipmentModal(context, order),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Create Shipment',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 4 Navigation Tabs: Items | Address | Payment | Status History (Matches Panel 10 of img.png)
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailTabButton('Items', 0),
                _buildDetailTabButton('Address', 1),
                _buildDetailTabButton('Payment', 2),
                _buildDetailTabButton('Status History', 3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tab Body Content
        if (controller.orderDetailTabIndex.value == 0)
          _buildOrderItemsTable(order)
        else if (controller.orderDetailTabIndex.value == 1)
          _buildOrderAddressTab(order)
        else if (controller.orderDetailTabIndex.value == 2)
          _buildOrderPaymentTab(order)
        else
          _buildOrderStatusHistoryTab(order),
      ],
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String primaryText,
    required String secondaryText,
    bool isLargeValue = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isLargeValue
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            primaryText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isLargeValue ? 19 : 14.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            secondaryText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTabButton(String label, int tabIdx) {
    final isSelected = controller.orderDetailTabIndex.value == tabIdx;
    return InkWell(
      onTap: () => controller.orderDetailTabIndex.value = tabIdx,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  /// Renders the exact Product | Variant | Qty | Price | Subtotal table from Panel 10 of `lib/docs/img.png`
  /// with responsive mobile line-item support on narrow screens.
  Widget _buildOrderItemsTable(OrderModel order) {
    final items = order.items ?? const [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactMobile = constraints.maxWidth < 520;

        if (isCompactMobile) {
          return Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFF1F5F9),
                        child: item.productImageUrl != null &&
                                item.productImageUrl!.isNotEmpty
                            ? Image.network(
                                item.productImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.checkroom_outlined,
                                  size: 22,
                                  color: Color(0xFF64748B),
                                ),
                              )
                            : const Icon(
                                Icons.shopping_bag_outlined,
                                size: 22,
                                color: Color(0xFF64748B),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName ?? 'Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${item.sku ?? item.productId} • Variant: ${item.variantName ?? "Standard"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Product',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Variant',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Subtotal',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Table Rows
              ...items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: const Color(0xFFF1F5F9),
                                child: item.productImageUrl != null &&
                                        item.productImageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.productImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.checkroom_outlined,
                                          size: 22,
                                          color: Color(0xFF64748B),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 22,
                                        color: Color(0xFF64748B),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName ?? 'Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${item.sku ?? item.productId}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.variantName ?? 'Standard',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderAddressTab(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Customer Delivery Address',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Recipient: ${order.customerName ?? "Sok Dara"} (${order.customerPhone ?? "+855 96 123 4567"})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.shippingAddressText ??
                'No. 168 Russian Federation Blvd (110), Toul Kork, Phnom Penh, Cambodia',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(
            'Address ID: ${order.shippingAddressId ?? "adr-000001"}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPaymentTab(OrderModel order) {
    final p = order.payment;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Record (Step 8 & 9)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              _buildOrderStatusPill(p?.status ?? 'succeeded'),
            ],
          ),
          const SizedBox(height: 12),
          Text('Payment ID: ${p?.id ?? "pay-20261024-0001"}'),
          const SizedBox(height: 4),
          Text('Provider: ${p?.provider ?? "internal_mock"}'),
          const SizedBox(height: 4),
          Text(
            'Amount Paid: \$${(p?.amount ?? order.totalAmount).toStringAsFixed(2)} ${order.currency}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('Paid At: ${_formatDateTime(p?.paidAt ?? order.createdAt)}'),
        ],
      ),
    );
  }

  Widget _buildOrderStatusHistoryTab(OrderModel order) {
    final history = order.statusHistory ?? const [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isEmpty)
            const Text('No status transitions recorded.')
          else
            ...history.map((h) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.fromStatus != null
                                ? '${h.fromStatus!.toUpperCase()} → ${h.toStatus.toUpperCase()}'
                                : h.toStatus.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          if (h.note != null && h.note!.isNotEmpty)
                            Text(
                              h.note!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                              ),
                            ),
                          Text(
                            _formatDateTime(h.createdAt),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Right Column: Order Timeline & Shipments Card (Matches Panels 10 & 11 of `lib/docs/img.png`)
  Widget _buildOrderRightTimeline(
    BuildContext context,
    OrderModel order,
    List<OrderShipmentModel> orderShipments,
  ) {
    final s = order.status.toLowerCase();
    // 0: Pending (Placed), 1: Confirmed (Approved), 2: Processing, 3: Shipped, 4: Delivered
    int stageIndex = 1;
    if (s == OrderStatus.pending) stageIndex = 0;
    if (s == OrderStatus.confirmed) stageIndex = 1;
    if (s == OrderStatus.processing) stageIndex = 2;
    if (s == OrderStatus.shipped) stageIndex = 3;
    if (s == OrderStatus.delivered || s == OrderStatus.completed) {
      stageIndex = 5; // All completed
    }

    final timelineSteps = [
      (
        label: 'Pending (Customer Placed)',
        time: _formatDateTime(order.createdAt, short: true),
        done: stageIndex > 0,
        active: stageIndex == 0,
      ),
      (
        label: 'Confirmed (Admin Approved)',
        time: stageIndex >= 1
            ? _formatDateTime(order.updatedAt ?? order.createdAt, short: true)
            : null,
        done: stageIndex > 1,
        active: stageIndex == 1,
      ),
      (
        label: 'Processing (Preparing)',
        time: stageIndex >= 2 ? 'Oct 24, 10:45' : null,
        done: stageIndex > 2,
        active: stageIndex == 2,
      ),
      (
        label: 'Shipped (In Transit)',
        time: stageIndex >= 3 ? 'Oct 24, 11:30' : null,
        done: stageIndex > 3,
        active: stageIndex == 3,
      ),
      (
        label: 'Delivered',
        time: stageIndex >= 4 ? 'Oct 24, 16:36' : null,
        done: stageIndex >= 4,
        active: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Timeline Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < timelineSteps.length; i++)
                _buildVerticalTimelineStep(
                  label: timelineSteps[i].label,
                  time: timelineSteps[i].time,
                  isDone: timelineSteps[i].done,
                  isActive: timelineSteps[i].active,
                  isLast: i == timelineSteps.length - 1,
                ),
            ],
          ),
        ),

        // Shipments Card (Matches bottom-right of Panel 11 in img.png: "ship-000001 Pending > Created: Oct 24, 10:50")
        if (orderShipments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipments',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ...orderShipments.map((sh) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => controller.openShipmentDetail(sh),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sh.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildOrderStatusPill(sh.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${_formatDateTime(sh.createdAt, short: true)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalTimelineStep({
    required String label,
    String? time,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    Widget iconWidget;
    if (isActive) {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBFDBFE), width: 3),
        ),
        child: const Center(
          child: Icon(Icons.circle, size: 8, color: Colors.white),
        ),
      );
    } else if (isDone) {
      iconWidget = const Icon(
        Icons.check_circle,
        color: Color(0xFF16A34A),
        size: 22,
      );
    } else {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              iconWidget,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isActive || isDone
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : (isDone
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                  if (time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Panel 11 Modal Dialog: "Create Shipment?"
  // ──────────────────────────────────────────────────────────
  Future<void> _showCreateShipmentModal(
    BuildContext context,
    OrderModel order,
  ) async {
    final noteController = TextEditingController(
      text: 'Store started preparing the fulfillment',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Create Shipment?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This will change the shipment for this order with status Pending.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note (optional)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Shipment created for fulfillment',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(100, 42),
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final note = noteController.text.trim();
                          Navigator.of(dialogContext).pop();
                          await controller.createShipmentForOrder(
                            order.id,
                            note: note,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(110, 42),
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
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
  }

  Future<void> _showCancelOrFailDialog(
    BuildContext context,
    OrderModel order, {
    required bool isCancel,
  }) async {
    final noteCtrl = TextEditingController(
      text: isCancel
          ? 'Customer requested order cancellation'
          : 'Fulfillment could not be completed',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCancel ? 'Cancel Order?' : 'Mark Order Failed?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reserved variant stock will be automatically restored and internal payment logically refunded.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Audit Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.cancelOrFailOrder(
                order.id,
                isCancel: isCancel,
                note: noteCtrl.text,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(110, 40),
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(isCancel ? 'Confirm Cancel' : 'Mark Failed'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // All Platform Orders Table View
  // ──────────────────────────────────────────────────────────
  Widget _buildAllOrdersTableCard(BuildContext context) {
    final statuses = [
      'all',
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
      OrderStatus.cancelled,
    ];

    final list = controller.filteredOrders;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'All Platform Orders (/api/v1/admin/orders/)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: (v) => controller.orderSearchQuery.value = v,
                  decoration: InputDecoration(
                    hintText: 'Search order ID, customer, store...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((st) {
                final selected = controller.orderStatusFilter.value == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      st == 'all' ? 'All Orders' : _statusDisplay(st),
                    ),
                    selected: selected,
                    onSelected: (_) => controller.orderStatusFilter.value = st,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...list.map((ord) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.openOrderDetail(ord),
                            child: Text(
                              ord.orderNumber ?? ord.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                        _buildOrderStatusPill(ord.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ord.customerName ?? 'Customer'} • ${ord.storeName ?? 'Store'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(ord.createdAt, short: true),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          '\$${ord.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (ord.status.toLowerCase() == OrderStatus.pending)
                              ElevatedButton.icon(
                                onPressed: controller.isPerformingAction.value
                                    ? null
                                    : () => controller.approveCustomerOrder(
                                          ord.id,
                                          autoStartPreparing: false,
                                        ),
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Approve (Step 9)',
                                  style: TextStyle(fontSize: 11.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: () => controller.openOrderDetail(ord),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 34),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Open Fulfillment',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
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

  Widget _buildOrderStatusPill(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    String label = _statusDisplay(status);

    switch (s) {
      case OrderStatus.confirmed:
      case OrderStatus.delivered:
      case PaymentStatus.succeeded:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case OrderStatus.processing:
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case OrderStatus.shipped:
      case ShipmentStatus.inTransit:
      case ShipmentStatus.packed:
      case ShipmentStatus.outForDelivery:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _statusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'packed':
        return 'Packed';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Failed';
      case 'succeeded':
        return 'Succeeded';
      default:
        return status;
    }
  }
}
