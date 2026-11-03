import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'admin_fulfillment_flow_banner.dart';

/// Executive Overview Dashboard View (Module Index 0).
class AdminOverviewView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminOverviewView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final orders = controller.orders;
      final shipments = controller.shipments;
      final products = controller.products;
      final customers = controller.users;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Executive Revenue & Quick-Action Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: Color(0xFF4ADE80),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'GROSS REVENUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${orders.length} Orders • ${shipments.length} Shipments',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${controller.totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SETEC eCommerce Fulfillment & Storefront Control',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.selectNav(1),
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Fulfill Orders',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E3A8A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.approvalSubTabIndex.value = 0;
                          controller.selectNav(4);
                        },
                        icon: const Icon(Icons.verified_outlined, size: 16),
                        label: Text(
                          'Approvals (${controller.awaitingApprovalOrdersCount + controller.pendingApprovalProductsCount})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 Modern Metric Grid
          Row(
            children: [
              Expanded(
                child: _OverviewKpiCard(
                  title: 'Orders',
                  value: '${orders.length}',
                  subtitle: 'Steps 10–11',
                  badgeText: 'Queue',
                  icon: Icons.inbox_rounded,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () => controller.selectNav(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewKpiCard(
                  title: 'Shipments',
                  value: '${shipments.length}',
                  subtitle: 'Steps 12–17',
                  badgeText: 'Transit',
                  icon: Icons.local_shipping_rounded,
                  accentColor: const Color(0xFF0284C7),
                  onTap: () => controller.selectNav(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OverviewKpiCard(
                  title: 'Products',
                  value: '${products.length}',
                  subtitle: '${controller.approvedProductsCount} live',
                  badgeText: 'Catalog',
                  icon: Icons.inventory_2_rounded,
                  accentColor: const Color(0xFF16A34A),
                  onTap: () => controller.selectNav(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewKpiCard(
                  title: 'Customers',
                  value: '${customers.length}',
                  subtitle: 'Active accounts',
                  badgeText: 'Users',
                  icon: Icons.people_alt_rounded,
                  accentColor: const Color(0xFF7C3AED),
                  onTap: () => controller.selectNav(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Step 10 -> 17 Fulfillment Pipeline Card
          AdminFulfillmentFlowBanner(controller: controller),
          const SizedBox(height: 14),

          // Two-column or Stacked Recent Orders + Approvals
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildRecentOrdersCard()),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: _buildPendingApprovalsCard()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRecentOrdersCard(),
                  const SizedBox(height: 14),
                  _buildPendingApprovalsCard(),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildOrderStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFEFF6FF);
    Color fg = const Color(0xFF1D4ED8);
    if (s == 'confirmed' || s == 'delivered') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (s == 'processing' || s == 'pending') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else if (s == 'cancelled' || s == 'failed') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    final orders = controller.orders;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Tap an order to manage fulfillment',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => controller.selectNav(1),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final order = orders[index];
              final itemCount = order.items?.length ?? order.itemCount ?? 0;
              final customerName = order.customerName ?? 'Customer';
              final initial = customerName.isNotEmpty
                  ? customerName[0].toUpperCase()
                  : 'C';

              return InkWell(
                onTap: () => controller.openOrderDetail(order),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  order.orderNumber ?? order.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                _buildOrderStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$customerName • $itemCount items • \$${order.totalAmount.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (order.status.toLowerCase() == 'pending') ...[
                        InkWell(
                          onTap: controller.isPerformingAction.value
                              ? null
                              : () => controller.approveCustomerOrder(
                                    order.id,
                                    autoStartPreparing: false,
                                  ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF86EFAC),
                              ),
                            ),
                            child: const Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard() {
    final pendingProducts =
        controller.products.where((p) => !p.isApproved).toList();
    final displayList = pendingProducts.isNotEmpty
        ? pendingProducts
        : controller.products.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Approvals',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Review & publish catalog listings',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => controller.selectNav(4),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final prod = displayList[index];
              final isApproved = prod.isApproved;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 42,
                        height: 42,
                        color: const Color(0xFFF1F5F9),
                        child: prod.imageUrl != null &&
                                prod.imageUrl!.isNotEmpty
                            ? Image.network(
                                prod.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 19,
                                  color: Color(0xFF64748B),
                                ),
                              )
                            : const Icon(
                                Icons.inventory_2_outlined,
                                size: 19,
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
                            prod.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${prod.storeName} • \$${prod.basePrice.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isApproved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => controller.updateProductApprovalStatus(
                          prod,
                          'active',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 32),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Approve'),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _OverviewKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reports, Support Tickets, Broadcast Notifications & Legal Documents View (Module Index 6).
class AdminReportsView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminReportsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support Desk & Governance',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Customer support tickets, broadcast alerts & legal policies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showBroadcastDialog(context),
                        icon: const Icon(Icons.campaign_outlined, size: 17),
                        label: const Text(
                          'Broadcast Alert',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showLegalDocumentDialog(context),
                        icon: const Icon(Icons.gavel_outlined, size: 16),
                        label: const Text(
                          '+ Legal Policy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Support Tickets Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customer Support Tickets',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.tickets.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final ticket = controller.tickets[index];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  ticket.subject,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildTicketStatusChip(ticket.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ticket.customerName} • Priority: ${ticket.priority.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...ticket.messages.map(
                            (m) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: m.isAdmin
                                    ? const Color(0xFFEFF6FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    m.isAdmin
                                        ? Icons.shield_outlined
                                        : Icons.person_outline,
                                    size: 15,
                                    color: m.isAdmin
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${m.senderName}: ${m.body}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showReplyTicketDialog(context, ticket),
                                icon: const Icon(Icons.reply, size: 14),
                                label: const Text('Reply'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (ticket.status != 'resolved') ...[
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => controller.updateTicket(
                                    ticket.id,
                                    status: 'resolved',
                                  ),
                                  icon: const Icon(Icons.check, size: 14),
                                  label: const Text('Resolve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Broadcast Notifications + Legal Documents
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildNotificationsCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLegalDocsCard()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildNotificationsCard(),
                  const SizedBox(height: 14),
                  _buildLegalDocsCard(),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildTicketStatusChip(String status) {
    final isResolved = status == 'resolved' || status == 'closed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isResolved ? const Color(0xFF15803D) : const Color(0xFFB45309),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text(
              'Broadcast Notifications',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2563EB),
                    size: 17,
                  ),
                ),
                title: Text(
                  notif.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '${notif.body}\nTarget: ${notif.targetLabel}',
                  style: const TextStyle(fontSize: 11.5),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDocsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text(
              'Legal Policies & Terms',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.legalDocs.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final doc = controller.legalDocs[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF334155),
                    size: 17,
                  ),
                ),
                title: Text(
                  '${doc.title} (v${doc.version})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Type: ${doc.type} • ${doc.status.toUpperCase()}',
                  style: const TextStyle(fontSize: 11.5),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReplyTicketDialog(BuildContext context, AdminSupportTicket ticket) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${ticket.customerName}'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: msgCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Support Reply Message',
              hintText: 'Enter message to customer...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = msgCtrl.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop();
              controller.replyToTicket(ticket.id, text);
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Broadcast Notification'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message Body'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final b = bodyCtrl.text.trim();
              if (t.isEmpty || b.isEmpty) return;
              Navigator.of(ctx).pop();
              controller.sendNotification(
                userId: 'all',
                targetLabel: 'All Customers',
                type: 'promotion',
                title: t,
                body: b,
              );
            },
            child: const Text('Broadcast Now'),
          ),
        ],
      ),
    );
  }

  void _showLegalDocumentDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'terms');
    final versionCtrl = TextEditingController(text: '2.1');
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Legal Document'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Document Title'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: typeCtrl,
                      decoration: const InputDecoration(labelText: 'Doc Type'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: versionCtrl,
                      decoration: const InputDecoration(labelText: 'Version'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Legal Content / Markdown',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.of(ctx).pop();
              controller.saveLegalDocument(
                AdminLegalDocument(
                  id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  type: typeCtrl.text.trim(),
                  version: versionCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  status: 'published',
                  publishedAt: DateTime.now(),
                ),
              );
            },
            child: const Text('Save Document'),
          ),
        ],
      ),
    );
  }
}

/// Admin Settings View (Module Index 7).
class AdminSettingsView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminSettingsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final email = controller.adminEmail.value.isNotEmpty
          ? controller.adminEmail.value
          : 'admin@setec.edu.kh';
      final name = controller.adminName.value;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF2563EB),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'ROLE: ${controller.adminRole.value.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.resetDemoOrderFlow,
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text(
                          'Reset Demo Flow',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await controller.logoutAdminSession();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 12.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // System & Session Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFF2563EB),
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Session & System Overview',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22, color: Color(0xFFF1F5F9)),
                _buildSettingInfoRow(
                  label: 'Account Email',
                  value: email,
                ),
                const SizedBox(height: 10),
                _buildSettingInfoRow(
                  label: 'Role Privilege',
                  value: controller.adminRole.value.toUpperCase(),
                ),
                const SizedBox(height: 10),
                _buildSettingInfoRow(
                  label: 'Fulfillment Pipeline',
                  value: 'Steps 10–17 Active',
                ),
                const SizedBox(height: 10),
                _buildSettingInfoRow(
                  label: 'Catalog Status',
                  value:
                      '${controller.products.length} SKUs • ${controller.pendingApprovalProductsCount} Pending',
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSettingInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
