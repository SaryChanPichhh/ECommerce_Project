import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Implements Panels 12, 13, 14–15, and 16–17 from `lib/docs/img.png`:
/// - Step 12: Shipment Detail & "Mark as Packed?" modal
/// - Step 13: Shipment Handoff & Carrier Information form
/// - Step 14 & 15: Shipment Tracking Events & "+ Mark Out for Delivery"
/// - Step 16 & 17: Delivery Confirmation & Order Summary
class AdminShipmentsView extends StatefulWidget {
  final AdminDashboardController controller;

  const AdminShipmentsView({
    super.key,
    required this.controller,
  });

  @override
  State<AdminShipmentsView> createState() => _AdminShipmentsViewState();
}

class _AdminShipmentsViewState extends State<AdminShipmentsView> {
  String _selectedCarrier = 'DHL Express';
  final _trackingCtrl = TextEditingController(text: 'DHL-123456');
  final _locationCtrl = TextEditingController(text: 'Phnom Penh warehouse');
  final _handoffNoteCtrl =
      TextEditingController(text: 'Package handed to carrier');

  AdminDashboardController get controller => widget.controller;

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _locationCtrl.dispose();
    _handoffNoteCtrl.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dt, {bool short = false}) {
    if (dt == null) return 'Oct 24, 10:50';
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
      final currentShipment = controller.selectedShipment.value ??
          (controller.shipments.isNotEmpty ? controller.shipments.first : null);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShipmentSelectorBar(currentShipment),
          const SizedBox(height: 16),

          if (controller.showShipmentListTable.value || currentShipment == null)
            _buildAllShipmentsTableCard()
          else
            _buildShipmentStageWorkspace(context, currentShipment),
        ],
      );
    });
  }

  Widget _buildShipmentSelectorBar(OrderShipmentModel? currentShipment) {
    final isListMode = controller.showShipmentListTable.value;
    final shipId = currentShipment?.id ?? '';

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
          // Breadcrumb: ← Shipments / ship-000001
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => controller.showShipmentListTable.value = true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Shipments',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isListMode
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isListMode && shipId.isNotEmpty) ...[
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
                  shipId,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ],
          ),

          // Shipment Selector Chips + All Shipments Table Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Shipment:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                ...controller.shipments.map((sh) {
                  final selected =
                      !isListMode && currentShipment?.id == sh.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        '${sh.id} (${_statusDisplay(sh.status)})',
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
                      onSelected: (_) => controller.openShipmentDetail(sh),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () {
                    controller.showShipmentListTable.value =
                        !controller.showShipmentListTable.value;
                  },
                  icon: Icon(
                    isListMode
                        ? Icons.local_shipping_outlined
                        : Icons.table_chart_outlined,
                    size: 16,
                  ),
                  label: Text(
                    isListMode ? 'Shipment Detail View' : 'All Shipments Table',
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
  // Panels 12, 13, 14–15, 16–17 Shipment Workspace
  // ──────────────────────────────────────────────────────────
  Widget _buildShipmentStageWorkspace(
    BuildContext context,
    OrderShipmentModel shipment,
  ) {
    final s = shipment.status.toLowerCase();
    final isPending = s == ShipmentStatus.pending;
    final isPacked = s == ShipmentStatus.packed;
    final isInTransit = s == ShipmentStatus.inTransit;
    final isOutForDelivery = s == ShipmentStatus.outForDelivery;
    final isDelivered = s == ShipmentStatus.delivered;
    final parentOrder = controller.findOrderForShipment(shipment);

    String stepBadge = '12';
    String stepHeaderTitle = 'Products are packed  (Shipment → Packed)';
    String panelMainTitle = 'Shipment Detail';

    if (isPending) {
      stepBadge = '12';
      stepHeaderTitle = 'Products are packed  (Shipment → Packed)';
      panelMainTitle = 'Shipment Detail';
    } else if (isPacked) {
      stepBadge = '13';
      stepHeaderTitle =
          'Package is handed to the carrier  (Order → Shipped, Shipment → In Transit)';
      panelMainTitle = 'Shipment Handoff';
    } else if (isInTransit) {
      stepBadge = '14 & 15';
      stepHeaderTitle = 'Record tracking events  &  Out for delivery';
      panelMainTitle = 'Shipment Tracking';
    } else if (isOutForDelivery || isDelivered) {
      stepBadge = '16 & 17';
      stepHeaderTitle = 'Customer confirms receipt  &  Delivered';
      panelMainTitle = 'Delivery Confirmation';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Context Banner
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
                  stepBadge,
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
                  stepHeaderTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              if (parentOrder != null)
                TextButton.icon(
                  onPressed: () => controller.openOrderDetail(parentOrder),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: Text(
                    'Order: ${parentOrder.orderNumber ?? parentOrder.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main Shipment White Card
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
              // Header Row: Panel Title + Shipment ID + Status Pill + Primary Action Button / Green Toast Pills
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
                        panelMainTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            shipment.id,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusPill(shipment.status),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons on Right (Matches Panels 12, 13, 14–15, 16–17)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Step 12: "✓ Mark as Packed"
                      if (isPending)
                        ElevatedButton.icon(
                          onPressed: controller.isPerformingAction.value
                              ? null
                              : () => _showMarkAsPackedModal(context, shipment),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text(
                            'Mark as Packed',
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
                          ),
                        ),

                      // Step 13: "🚚 Handoff to Carrier"
                      if (isPacked)
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.isHandoffFormOpen.value = true;
                          },
                          icon: const Icon(
                            Icons.local_shipping_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Handoff to Carrier',
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
                          ),
                        ),

                      // Step 14 & 15: "+ Record Tracking Event" & "+ Mark Out for Delivery"
                      if (isInTransit) ...[
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showRecordTrackingEventModal(context, shipment),
                          icon: const Icon(
                            Icons.add_location_alt_outlined,
                            size: 18,
                          ),
                          label: const Text('Record Tracking Event (Step 14)'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showMarkOutForDeliveryModal(context, shipment),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Mark Out for Delivery',
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
                          ),
                        ),
                      ],

                      // Step 16 & 17: Customer Confirms Receipt -> Delivered
                      if (isOutForDelivery)
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showConfirmDeliveryModal(context, shipment),
                          icon: const Icon(
                            Icons.verified_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Confirm Receipt & Mark Delivered (Step 16 & 17)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                          ),
                        ),

                      // Green Transition Toast Badges (Panels 12, 13, 16)
                      if (isDelivered) ...[
                        _buildGreenBannerBadge('Shipment → Delivered'),
                        _buildGreenBannerBadge('Order → Delivered'),
                      ] else if (controller.recentStatusBanners.isNotEmpty)
                        ...controller.recentStatusBanners
                            .map(_buildGreenBannerBadge),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3-Column Responsive Layout matching Panels 12, 13, 14–15, 16–17 of `lib/docs/img.png`:
              // Column 1 (Left, 24%): Shipment Progress Vertical Stepper
              // Column 2 (Center, 48%): Stage-specific Content (Shipment Info / Carrier Handoff Form / Tracking Events / Delivery Confirmation)
              // Column 3 (Right, 28%): Order Status / Shipment Progress Summary / Order Summary
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 860;
                  final leftProgress = _buildShipmentProgressColumn(shipment);
                  final centerContent = _buildCenterStageColumn(
                    context,
                    shipment,
                    parentOrder,
                  );
                  final rightSidebar = _buildRightSummaryColumn(
                    shipment,
                    parentOrder,
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: leftProgress),
                        const SizedBox(width: 22),
                        Expanded(flex: 5, child: centerContent),
                        const SizedBox(width: 22),
                        Expanded(flex: 3, child: rightSidebar),
                      ],
                    );
                  }
                  if (constraints.maxWidth >= 560) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        centerContent,
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: leftProgress),
                            const SizedBox(width: 16),
                            Expanded(child: rightSidebar),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      centerContent,
                      const SizedBox(height: 16),
                      leftProgress,
                      const SizedBox(height: 16),
                      rightSidebar,
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

  Widget _buildGreenBannerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Left Column: Shipment Progress Vertical Stepper
  // ──────────────────────────────────────────────────────────
  Widget _buildShipmentProgressColumn(OrderShipmentModel shipment) {
    final s = shipment.status.toLowerCase();
    int stageIdx = 0; // 0: Pending, 1: Packed, 2: In Transit, 3: Out for Delivery, 4: Delivered
    if (s == ShipmentStatus.packed) stageIdx = 1;
    if (s == ShipmentStatus.inTransit) stageIdx = 2;
    if (s == ShipmentStatus.outForDelivery) stageIdx = 3;
    if (s == ShipmentStatus.delivered) stageIdx = 5;

    final steps = [
      (
        label: 'Pending',
        time: 'Oct 24, 10:50',
        done: stageIdx > 0,
        active: stageIdx == 0,
      ),
      (
        label: 'Packed',
        time: stageIdx >= 1 ? 'Oct 24, 11:15' : null,
        done: stageIdx > 1,
        active: stageIdx == 1,
      ),
      (
        label: 'In Transit',
        time: stageIdx >= 2 ? 'Oct 24, 11:30' : null,
        done: stageIdx > 2,
        active: stageIdx == 2,
      ),
      (
        label: 'Out for Delivery',
        time: stageIdx >= 3 ? 'Oct 24, 16:00' : null,
        done: stageIdx > 3,
        active: stageIdx == 3,
      ),
      (
        label: 'Delivered',
        time: stageIdx >= 4 ? 'Oct 24, 16:36' : null,
        done: stageIdx >= 4,
        active: false,
      ),
    ];

    return Container(
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
            'Shipment Progress',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < steps.length; i++)
            _buildStepperRow(
              label: steps[i].label,
              time: steps[i].time,
              isDone: steps[i].done,
              isActive: steps[i].active,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildStepperRow({
    required String label,
    String? time,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    Widget dot;
    if (isActive) {
      dot = Container(
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
      dot = const Icon(
        Icons.check_circle,
        color: Color(0xFF16A34A),
        size: 22,
      );
    } else {
      dot = Container(
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
              dot,
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
  // Center Column: Context-Aware Stage Content (Panels 12, 13, 14–15, 16–17)
  // ──────────────────────────────────────────────────────────
  Widget _buildCenterStageColumn(
    BuildContext context,
    OrderShipmentModel shipment,
    OrderModel? parentOrder,
  ) {
    final s = shipment.status.toLowerCase();

    // Panel 13: Carrier Information Handoff Form when Packed (or when Handoff button is clicked)
    if (s == ShipmentStatus.packed || controller.isHandoffFormOpen.value) {
      return _buildCarrierInformationFormCard(shipment);
    }

    // Panel 14 & 15: Tracking Events (n) | Details when In Transit
    if (s == ShipmentStatus.inTransit) {
      return _buildShipmentTrackingEventsPanel(context, shipment);
    }

    // Panel 16 & 17: Delivery Confirmation when Out for Delivery or Delivered
    if (s == ShipmentStatus.outForDelivery || s == ShipmentStatus.delivered) {
      return _buildDeliveryConfirmationPanel(context, shipment, parentOrder);
    }

    // Panel 12 Default (Pending): Shipment Information + Note Card
    return _buildPendingShipmentInformationPanel(context, shipment);
  }

  /// Panel 12 Center Content: Shipment Information + Note
  Widget _buildPendingShipmentInformationPanel(
    BuildContext context,
    OrderShipmentModel shipment,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                'Shipment Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildKeyValRow('Order ID', shipment.orderId ?? 'ord-20261024-0001'),
              const Divider(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildStatusPill(shipment.status),
                ],
              ),
              const Divider(height: 20),
              _buildKeyValRow(
                'Created At',
                _formatDateTime(shipment.createdAt, short: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                'Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shipment.note ?? 'Shipment created for fulfillment.',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Panel 13 Center Content: Carrier Information Handoff Form
  Widget _buildCarrierInformationFormCard(OrderShipmentModel shipment) {
    const carriers = [
      'DHL Express',
      'J&T Express',
      'Virak Buntham Express',
      'Cambodia Post',
      'FedEx International',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carrier Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Carrier Name *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedCarrier,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: carriers
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedCarrier = v);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Tracking Number *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _trackingCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'DHL-123456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Location *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Phnom Penh warehouse',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
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
            controller: _handoffNoteCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Package handed to carrier',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.isHandoffFormOpen.value = false;
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(100, 42),
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: controller.isPerformingAction.value
                    ? null
                    : () async {
                        await controller.handoffShipmentToCarrier(
                          shipment.id,
                          carrierName: _selectedCarrier,
                          trackingNumber: _trackingCtrl.text.trim().isEmpty
                              ? 'DHL-123456'
                              : _trackingCtrl.text.trim(),
                          location: _locationCtrl.text.trim().isEmpty
                              ? 'Phnom Penh warehouse'
                              : _locationCtrl.text.trim(),
                          note: _handoffNoteCtrl.text.trim(),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(115, 42),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Handoff',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Panel 14 & 15 Center Content: Tracking Events (n) | Details
  Widget _buildShipmentTrackingEventsPanel(
    BuildContext context,
    OrderShipmentModel shipment,
  ) {
    final tabIdx = controller.shipmentTrackingTabIndex.value;
    final events = shipment.events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs: Tracking Events (n) | Details
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
                InkWell(
                  onTap: () => controller.shipmentTrackingTabIndex.value = 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: tabIdx == 0
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Tracking Events (${events.length})',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: tabIdx == 0
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => controller.shipmentTrackingTabIndex.value = 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: tabIdx == 1
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: tabIdx == 1
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (tabIdx == 0)
          ...events.map((ev) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(ev.eventTime, short: true),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ev.description ?? 'Tracking checkpoint recorded',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (ev.location != null && ev.location!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            ev.location!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          })
        else
          _buildPendingShipmentInformationPanel(context, shipment),
      ],
    );
  }

  /// Panel 16 & 17 Center Content: Delivery Confirmation Card
  Widget _buildDeliveryConfirmationPanel(
    BuildContext context,
    OrderShipmentModel shipment,
    OrderModel? parentOrder,
  ) {
    final isDelivered = shipment.status.toLowerCase() == ShipmentStatus.delivered;
    final customerName = parentOrder?.customerName ?? 'Sok Dara';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Confirmation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDelivered
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDelivered
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFF93C5FD),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDelivered
                      ? Icons.check_circle_outline
                      : Icons.delivery_dining_outlined,
                  color: isDelivered
                      ? const Color(0xFF15803D)
                      : const Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isDelivered
                        ? 'Customer Confirmed Delivery'
                        : 'Courier Out for Delivery — Awaiting Customer Receipt Confirmation',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDelivered
                          ? const Color(0xFF15803D)
                          : const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildKeyValRow(
            'Confirmed By',
            shipment.confirmedBy ?? 'Customer ($customerName)',
          ),
          const Divider(height: 22),
          _buildKeyValRow(
            'Confirmed At',
            isDelivered
                ? _formatDateTime(shipment.deliveredAt ?? DateTime(2026, 10, 24, 16, 36))
                : 'Pending Receipt',
          ),
          const Divider(height: 22),
          _buildKeyValRow(
            'Note',
            shipment.deliveryNote ??
                shipment.note ??
                'Product received in good condition',
          ),
          if (!isDelivered) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmDeliveryModal(context, shipment),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Simulate / Confirm Customer Receipt (Step 16 & 17)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Right Column: Order Status & Order Summary Card
  // ──────────────────────────────────────────────────────────
  Widget _buildRightSummaryColumn(
    OrderShipmentModel shipment,
    OrderModel? parentOrder,
  ) {
    final orderStatus = parentOrder?.status ??
        (shipment.status == ShipmentStatus.delivered
            ? OrderStatus.delivered
            : (shipment.status == ShipmentStatus.inTransit ||
                    shipment.status == ShipmentStatus.outForDelivery
                ? OrderStatus.shipped
                : OrderStatus.processing));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Status Box (Panel 13)
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
                'Order Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildKeyValRow(
                'Order ID',
                parentOrder?.orderNumber ??
                    shipment.orderId ??
                    'ord-20261024-0001',
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildStatusPill(orderStatus),
                ],
              ),
              if (shipment.carrierName != null &&
                  shipment.carrierName!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildKeyValRow('Carrier', shipment.carrierName!),
              ],
              if (shipment.trackingNumber != null &&
                  shipment.trackingNumber!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildKeyValRow('Tracking #', shipment.trackingNumber!),
              ],
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '\$${(parentOrder?.totalAmount ?? 80.00).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
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
    );
  }

  Widget _buildKeyValRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // Modals for Steps 12, 14, 15, 16 & 17
  // ──────────────────────────────────────────────────────────

  /// Panel 12 Modal: "Mark as Packed?"
  Future<void> _showMarkAsPackedModal(
    BuildContext context,
    OrderShipmentModel shipment,
  ) async {
    final noteCtrl = TextEditingController(
      text: 'Products packed and ready for pickup',
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
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Mark as Packed?',
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
                    'Confirm that the products have been packed and are ready for handoff.',
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
                    controller: noteCtrl,
                    decoration: InputDecoration(
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
                          final note = noteCtrl.text.trim();
                          Navigator.of(dialogContext).pop();
                          await controller.markShipmentAsPacked(
                            shipment.id,
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

  /// Step 14 Modal: Record Tracking Event (`POST /api/v1/admin/shipments/{id}/events`)
  Future<void> _showRecordTrackingEventModal(
    BuildContext context,
    OrderShipmentModel shipment,
  ) async {
    final locCtrl =
        TextEditingController(text: 'Phnom Penh sorting center');
    final descCtrl =
        TextEditingController(text: 'Package scanned at sorting center');

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Record Carrier Tracking Event (Step 14)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint Location *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint Description *',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(95, 40),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await controller.addShipmentTrackingEvent(
                          shipment.id,
                          location: locCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text('Add Event'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 15 Modal: Mark Out for Delivery (`PATCH /api/v1/admin/shipments/{id}/out-for-delivery`)
  Future<void> _showMarkOutForDeliveryModal(
    BuildContext context,
    OrderShipmentModel shipment,
  ) async {
    final locCtrl = TextEditingController(text: 'Phnom Penh delivery hub');
    final noteCtrl =
        TextEditingController(text: 'Courier is delivering the package');

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mark Out for Delivery? (Step 15)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Marks that a courier has the package and is taking it to the customer address today.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Hub Location *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(95, 40),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await controller.markShipmentOutForDelivery(
                          shipment.id,
                          location: locCtrl.text.trim(),
                          note: noteCtrl.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 16 & 17 Modal: Confirm Receipt -> Delivered
  Future<void> _showConfirmDeliveryModal(
    BuildContext context,
    OrderShipmentModel shipment,
  ) async {
    final parentOrder = controller.findOrderForShipment(shipment);
    final custName = parentOrder?.customerName ?? 'Sok Dara';
    final noteCtrl =
        TextEditingController(text: 'Product received in good condition');

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Customer Delivery Receipt (Steps 16 & 17)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transitions both Shipment and Order status to Delivered.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Confirmation Note',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(95, 40),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await controller.confirmShipmentDelivery(
                          shipment.id,
                          note: noteCtrl.text.trim(),
                          confirmedBy: 'Customer ($custName)',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 40),
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Delivered'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // All Shipments Mobile Cards
  // ──────────────────────────────────────────────────────────
  Widget _buildAllShipmentsTableCard() {
    final list = controller.filteredShipments;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Platform Shipments',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No shipments found',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...list.map((sh) {
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
                            onTap: () => controller.openShipmentDetail(sh),
                            child: Text(
                              sh.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                        _buildStatusPill(sh.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order: ${sh.orderId ?? '-'} • Carrier: ${sh.carrierName ?? 'Unassigned'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tracking: ${sh.trackingNumber ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.openShipmentDetail(sh),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'Manage',
                            style: TextStyle(fontSize: 12),
                          ),
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

  Widget _buildStatusPill(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;

    switch (s) {
      case ShipmentStatus.delivered:
      case OrderStatus.confirmed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case ShipmentStatus.pending:
      case OrderStatus.processing:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case ShipmentStatus.packed:
      case ShipmentStatus.inTransit:
      case ShipmentStatus.outForDelivery:
      case OrderStatus.shipped:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
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
        _statusDisplay(status),
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
      case 'packed':
        return 'Packed';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'shipped':
        return 'Shipped';
      case 'processing':
        return 'Processing';
      case 'confirmed':
        return 'Confirmed';
      default:
        return status;
    }
  }
}
