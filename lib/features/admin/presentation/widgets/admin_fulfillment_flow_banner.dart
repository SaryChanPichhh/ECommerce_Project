import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../orders/domain/entities/order.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Compact, modern Fulfillment Pipeline Card (Steps 10 – 17).
class AdminFulfillmentFlowBanner extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminFulfillmentFlowBanner({
    super.key,
    required this.controller,
  });

  int _resolveActiveStepIndex() {
    final ord = controller.selectedOrder.value;
    final ship = controller.selectedShipment.value;

    if (controller.selectedNavIndex.value == 2 && ship != null) {
      switch (ship.status.toLowerCase()) {
        case ShipmentStatus.pending:
          return 2; // Step 12: Pack (Packed)
        case ShipmentStatus.packed:
          return 3; // Step 13: Handoff (Shipped)
        case ShipmentStatus.inTransit:
          return 4; // Step 14 & 15: Tracking / Out for Delivery
        case ShipmentStatus.outForDelivery:
          return 6; // Step 16: Confirm (Receive)
        case ShipmentStatus.delivered:
          return 7; // Step 17: Delivered (Complete)
      }
    }

    if (ord != null) {
      final s = ord.status.toLowerCase();
      if (s == OrderStatus.confirmed || s == OrderStatus.pending) {
        return 0; // Step 10: Prepare (Processing)
      }
      if (s == OrderStatus.processing) {
        final hasShipment =
            controller.shipments.any((sh) => sh.orderId == ord.id);
        return hasShipment ? 2 : 1; // Step 11: Create Shipment
      }
      if (s == OrderStatus.shipped) {
        return 4;
      }
      if (s == OrderStatus.delivered) {
        return 7;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeStage = _resolveActiveStepIndex();

      const steps = <_FlowStepItem>[
        _FlowStepItem(
          stepNum: '10',
          title: 'Prepare',
          subtitle: 'Processing',
          icon: Icons.inventory_2_outlined,
        ),
        _FlowStepItem(
          stepNum: '11',
          title: 'Create',
          subtitle: 'Shipment',
          icon: Icons.add_box_outlined,
        ),
        _FlowStepItem(
          stepNum: '12',
          title: 'Pack',
          subtitle: 'Packed',
          icon: Icons.all_inbox_outlined,
        ),
        _FlowStepItem(
          stepNum: '13',
          title: 'Handoff',
          subtitle: 'Shipped',
          icon: Icons.local_shipping_outlined,
        ),
        _FlowStepItem(
          stepNum: '14',
          title: 'Tracking',
          subtitle: 'Events',
          icon: Icons.location_on_outlined,
        ),
        _FlowStepItem(
          stepNum: '15',
          title: 'Courier',
          subtitle: 'Out Delivery',
          icon: Icons.delivery_dining_outlined,
        ),
        _FlowStepItem(
          stepNum: '16',
          title: 'Confirm',
          subtitle: 'Receive',
          icon: Icons.verified_outlined,
          isGreen: true,
        ),
        _FlowStepItem(
          stepNum: '17',
          title: 'Delivered',
          subtitle: 'Complete',
          icon: Icons.check_circle_outline,
          isGreen: true,
        ),
      ];

      final progressPercent =
          ((activeStage + 1) / steps.length).clamp(0.0, 1.0);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header Row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: Color(0xFF2563EB),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fulfillment Pipeline',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Step ${steps[activeStage].stepNum}: ${steps[activeStage].title} (${steps[activeStage].subtitle})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: controller.resetDemoOrderFlow,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 13,
                          color: Color(0xFF334155),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 4,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  activeStage >= 6
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Interactive Pipeline Step Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    _buildStepCard(steps[i], i, activeStage),
                    if (i < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: i < activeStage
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStepCard(_FlowStepItem item, int index, int activeStage) {
    final isActive = index == activeStage;
    final isCompleted = index < activeStage;
    final accentColor =
        item.isGreen ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (index <= 1) {
            controller.selectNav(1);
          } else {
            controller.selectNav(2);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: 0.08)
                : (isCompleted
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? accentColor
                  : (isCompleted
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFE2E8F0)),
              width: isActive ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFDCFCE7)
                          : (isActive
                              ? accentColor
                              : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      item.stepNum,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isCompleted
                            ? const Color(0xFF15803D)
                            : (isActive
                                ? Colors.white
                                : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : item.icon,
                    size: 15,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : (isActive ? accentColor : const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isActive ? accentColor : const Color(0xFF0F172A),
                ),
              ),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? const Color(0xFF15803D)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowStepItem {
  final String stepNum;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGreen;

  const _FlowStepItem({
    required this.stepNum,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isGreen = false,
  });
}
