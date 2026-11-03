import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_approved_products_view.dart';
import '../widgets/admin_customers_view.dart';
import '../widgets/admin_orders_view.dart';
import '../widgets/admin_overview_reports_settings_view.dart';
import '../widgets/admin_products_view.dart';
import '../widgets/admin_shipments_view.dart';

/// SETEC Adaptive Admin App UI (Supports both Desktop Sidebar from `lib/docs/img.png`
/// and a sleek Mobile Responsive Shell).
class AdminDashboardPage extends GetView<AdminDashboardController> {
  const AdminDashboardPage({super.key});

  static const List<_AdminModuleItem> _modules = [
    _AdminModuleItem(
      index: 0,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      subtitle: 'Overview & KPIs',
    ),
    _AdminModuleItem(
      index: 1,
      icon: Icons.inbox_outlined,
      activeIcon: Icons.inbox_rounded,
      label: 'Orders',
      subtitle: 'Steps 10–11',
    ),
    _AdminModuleItem(
      index: 2,
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
      label: 'Shipments',
      subtitle: 'Steps 12–17',
    ),
    _AdminModuleItem(
      index: 3,
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Products',
      subtitle: 'Catalog & SKUs',
    ),
    _AdminModuleItem(
      index: 4,
      icon: Icons.verified_outlined,
      activeIcon: Icons.verified_rounded,
      label: 'Approvals',
      subtitle: 'QA & Reviews',
    ),
    _AdminModuleItem(
      index: 5,
      icon: Icons.people_outline,
      activeIcon: Icons.people_rounded,
      label: 'Customers',
      subtitle: 'Users & RBAC',
    ),
    _AdminModuleItem(
      index: 6,
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Reports',
      subtitle: 'Support & Legal',
    ),
    _AdminModuleItem(
      index: 7,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      subtitle: 'Admin Session',
    ),
  ];

  String? _badgeForModule(int index) {
    final pendingApprovals =
        controller.awaitingApprovalOrdersCount +
        controller.pendingApprovalProductsCount;
    if (index == 1 && controller.orders.isNotEmpty) {
      return '${controller.orders.length}';
    } else if (index == 2 && controller.shipments.isNotEmpty) {
      return '${controller.shipments.length}';
    } else if (index == 3 && controller.products.isNotEmpty) {
      return '${controller.products.length}';
    } else if (index == 4 && pendingApprovals > 0) {
      return '$pendingApprovals';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;
        if (isDesktop) {
          return _buildDesktopShell(context);
        }
        return _buildMobileShell(context);
      },
    );
  }

  // ──────────────────────────────────────────────────────────
  // DESKTOP / TABLET WIDE SHELL (Matches `lib/docs/img.png` Sidebar + Workspace)
  // ──────────────────────────────────────────────────────────
  Widget _buildDesktopShell(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Left Dark Navy Sidebar ("SETEC Admin")
          _buildDesktopSidebar(context),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(context),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.orders.isEmpty &&
                        controller.products.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563EB),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF2563EB),
                      onRefresh: () => controller.refreshAllData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                        child: _buildActiveSection(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 248,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Header: SETEC Admin
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SETEC',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Admin Console',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF334155)),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'MODULES',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // Navigation Items
            Expanded(
              child: Obx(() {
                final currentIdx = controller.selectedNavIndex.value;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: _modules.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final item = _modules[i];
                    final isSelected = currentIdx == item.index;
                    final badge = _badgeForModule(item.index);
                    final isWarningBadge = item.index == 4 &&
                        controller.pendingApprovalProductsCount > 0;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.selectNav(item.index),
                        borderRadius: BorderRadius.circular(11),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF1D4ED8),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB)
                                          .withValues(alpha: 0.32),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 19,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              if (badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : (isWarningBadge
                                            ? const Color(0xFFD97706)
                                                .withValues(alpha: 0.25)
                                            : const Color(0xFF334155)),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : (isWarningBadge
                                              ? const Color(0xFFFBBF24)
                                              : const Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Bottom Admin User Card
            const Divider(height: 1, color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Obx(() {
                final name = controller.adminName.value;
                final initial =
                    name.isNotEmpty ? name[0].toUpperCase() : 'A';
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              controller.adminRole.value.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF60A5FA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Logout Admin',
                        onPressed: () async {
                          await controller.logoutAdminSession();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFFF87171),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Obx(() {
        final sectionTitle = _getSectionTitle(
          controller.selectedNavIndex.value,
        );
        return Row(
          children: [
            // Breadcrumb & Active Section Title
            Row(
              children: [
                const Text(
                  'SETEC Admin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Live API Sync Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: controller.isPerformingAction.value
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: controller.isPerformingAction.value
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.isPerformingAction.value)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2563EB),
                      ),
                    )
                  else
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isPerformingAction.value
                        ? 'Syncing API...'
                        : 'Live System',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: controller.isPerformingAction.value
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Refresh Button
            IconButton(
              tooltip: 'Sync with Backend API',
              onPressed: () => controller.refreshAllData(),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),

            // Notifications Button with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Reports & Notifications',
                  onPressed: () => controller.selectNav(6),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: Color(0xFF334155),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),

            // Profile Pill
            InkWell(
              onTap: () => controller.selectNav(7),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        controller.adminName.value.isNotEmpty
                            ? controller.adminName.value[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.adminName.value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ──────────────────────────────────────────────────────────
  // MOBILE / COMPACT SHELL
  // ──────────────────────────────────────────────────────────
  Widget _buildMobileShell(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => controller.selectNav(0),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 10,
        title: Obx(() {
          final sectionTitle = _getSectionTitle(
            controller.selectedNavIndex.value,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${controller.adminName.value} • ${controller.adminRole.value.toUpperCase()}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          Obx(() {
            if (controller.isPerformingAction.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              );
            }
            return IconButton(
              tooltip: 'Sync with Backend API',
              onPressed: () => controller.refreshAllData(),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 21,
                color: Color(0xFF334155),
              ),
            );
          }),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Reports & Notifications',
                onPressed: () => controller.selectNav(6),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: Color(0xFF334155),
                ),
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Logout Admin',
            onPressed: () async {
              await controller.logoutAdminSession();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildMobileModuleTabBar(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.orders.isEmpty &&
            controller.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF2563EB),
          onRefresh: () => controller.refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            child: _buildActiveSection(),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final currentIdx = controller.selectedNavIndex.value;
        final bottomIdx = currentIdx <= 3 ? currentIdx : 4;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: const Color(0xFFDBEAFE),
            selectedIndex: bottomIdx,
            onDestinationSelected: (idx) {
              if (idx < 4) {
                controller.selectNav(idx);
              } else {
                _showMoreModulesSheet(context);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon:
                    Icon(Icons.dashboard_rounded, color: Color(0xFF2563EB)),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon:
                    Icon(Icons.inbox_rounded, color: Color(0xFF2563EB)),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Shipments',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon:
                    Icon(Icons.grid_view_rounded, color: Color(0xFF2563EB)),
                label: 'More',
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Scrollable horizontal pill bar for instant mobile switching across all 8 admin modules.
  Widget _buildMobileModuleTabBar() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Obx(() {
        final currentIdx = controller.selectedNavIndex.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          itemCount: _modules.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final item = _modules[i];
            final isSelected = currentIdx == item.index;
            final badge = _badgeForModule(item.index);

            return InkWell(
              onTap: () => controller.selectNav(item.index),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 15,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.22)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showMoreModulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'More Admin Modules',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Switch to Approvals, Customers, Support Desk, or Admin Settings',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                ..._modules.skip(4).map((m) {
                  final selected = controller.selectedNavIndex.value == m.index;
                  final badge = _badgeForModule(m.index);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFBFDBFE)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? null
                              : Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          selected ? m.activeIcon : m.icon,
                          size: 20,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                      title: Text(
                        m.label,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        m.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badge != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        controller.selectNav(m.index);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSectionTitle(int index) {
    switch (index) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Orders & Fulfillment';
      case 2:
        return 'Shipments & Tracking';
      case 3:
        return 'Products & Catalog';
      case 4:
        return 'Approvals & Reviews';
      case 5:
        return 'Customers & Users';
      case 6:
        return 'Reports & Support';
      case 7:
        return 'Admin Settings';
      default:
        return 'SETEC Admin';
    }
  }

  Widget _buildActiveSection() {
    switch (controller.selectedNavIndex.value) {
      case 0:
        return AdminOverviewView(controller: controller);
      case 1:
        return AdminOrdersView(controller: controller);
      case 2:
        return AdminShipmentsView(controller: controller);
      case 3:
        return AdminProductsView(controller: controller);
      case 4:
        return AdminApprovedProductsView(controller: controller);
      case 5:
        return AdminCustomersView(controller: controller);
      case 6:
        return AdminReportsView(controller: controller);
      case 7:
        return AdminSettingsView(controller: controller);
      default:
        return AdminOrdersView(controller: controller);
    }
  }
}

class _AdminModuleItem {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;

  const _AdminModuleItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.subtitle,
  });
}
