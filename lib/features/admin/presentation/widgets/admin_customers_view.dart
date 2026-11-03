import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/admin_models.dart';
import '../controllers/admin_dashboard_controller.dart';

/// User & Customer Control Management Web-UI Dashboard.
/// Allows managing Customers, Admins, Support Agents, account status (active/blocked),
/// customer order history lookup, and direct customer notification dispatch.
class AdminCustomersView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminCustomersView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalUsers = controller.users.length;
      final customerCount = controller.users
          .where((u) => u.role.toLowerCase() == 'customer')
          .length;
      final staffCount = controller.users
          .where((u) => u.role.toLowerCase() != 'customer')
          .length;
      final blockedCount = controller.users
          .where((u) => u.status.toLowerCase() == 'blocked')
          .length;

      final list = controller.filteredUsers;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary 2x2 Mobile KPI Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildUserKpiCard(
                      label: 'Total Accounts',
                      value: '$totalUsers',
                      icon: Icons.people_alt_outlined,
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        controller.userRoleFilter.value = 'all';
                        controller.userStatusFilter.value = 'all';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserKpiCard(
                      label: 'Customers',
                      value: '$customerCount',
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF16A34A),
                      onTap: () {
                        controller.userRoleFilter.value = 'customer';
                        controller.userStatusFilter.value = 'all';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUserKpiCard(
                      label: 'Admin & Staff',
                      value: '$staffCount',
                      icon: Icons.admin_panel_settings_outlined,
                      color: const Color(0xFF7C3AED),
                      onTap: () {
                        controller.userRoleFilter.value = 'admin';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserKpiCard(
                      label: 'Blocked',
                      value: '$blockedCount',
                      icon: Icons.block_flipped,
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        controller.userStatusFilter.value = 'blocked';
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter & Search Toolbar + Mobile User Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Users & Customers',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage profiles, RBAC roles, and status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showUserFormDialog(context, existing: null),
                      icon: const Icon(Icons.person_add_alt_1, size: 16),
                      label: const Text('Add User'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Mobile Search Input
                TextField(
                  onChanged: (v) => controller.userSearchQuery.value = v,
                  decoration: InputDecoration(
                    hintText: 'Search name, email, phone...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleChip('All Roles', 'all'),
                      const SizedBox(width: 8),
                      _buildRoleChip('Customers', 'customer'),
                      const SizedBox(width: 8),
                      _buildRoleChip('Admins', 'admin'),
                      const SizedBox(width: 8),
                      _buildRoleChip('Support', 'support'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'No user accounts found',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  ...list.map((u) => _buildMobileUserCard(context, u)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMobileUserCard(BuildContext context, AdminUserCustomer u) {
    final isBlocked = u.status.toLowerCase() == 'blocked';
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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      u.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBlocked
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBlocked ? 'Blocked' : 'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isBlocked
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${u.phone} • ${u.address}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${u.ordersCount} orders • \$${u.totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              DropdownButton<String>(
                value: ['customer', 'admin', 'support']
                        .contains(u.role.toLowerCase())
                    ? u.role.toLowerCase()
                    : 'customer',
                isDense: true,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: 'customer',
                    child: Text('Customer', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('👑 Admin', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 'support',
                    child: Text('🎧 Support', style: TextStyle(fontSize: 12)),
                  ),
                ],
                onChanged: (newRole) {
                  if (newRole != null) {
                    controller.changeUserRole(u, newRole);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Send Notification',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
                onPressed: () => _showSendNotificationDialog(context, u),
              ),
              IconButton(
                tooltip: isBlocked ? 'Unblock Account' : 'Block Account',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isBlocked ? Icons.lock_open_outlined : Icons.block_flipped,
                  size: 18,
                  color: isBlocked
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
                onPressed: () => controller.toggleUserStatus(u),
              ),
              IconButton(
                tooltip: 'Edit Profile',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showUserFormDialog(context, existing: u),
              ),
              IconButton(
                tooltip: 'Delete Record',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                onPressed: () => controller.deleteUserCustomer(u.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserKpiCard({
    required String label,
    required String value,
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
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String role) {
    final selected = controller.userRoleFilter.value == role;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFFF1F5F9),
      showCheckmark: false,
      onSelected: (_) {
        controller.userRoleFilter.value = role;
        controller.userStatusFilter.value = 'all';
      },
    );
  }

  Future<void> _showUserFormDialog(
    BuildContext context, {
    required AdminUserCustomer? existing,
  }) async {
    final isNew = existing == null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(
      text: existing?.phone ?? '+855 12 345 678',
    );
    final addrCtrl = TextEditingController(
      text: existing?.address ?? 'Phnom Penh, Cambodia',
    );
    final pwCtrl = TextEditingController(text: 'Password123!');
    String role = existing?.role ?? 'customer';
    String status = existing?.status ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNew
                        ? 'Create User / Customer Account'
                        : 'Edit User / Customer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Email Address *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  if (isNew) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: pwCtrl,
                      decoration: const InputDecoration(
                        labelText:
                            'Initial Password (registers via /api/v1/auth/register/)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: role,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: const [
                            DropdownMenuItem(
                              value: 'customer',
                              child: Text('Customer', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'support',
                              child: Text('Support', overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => role = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: status,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'blocked',
                              child: Text('Blocked', overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => status = v);
                          },
                        ),
                      ),
                    ],
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
                          final record = AdminUserCustomer(
                            id: existing?.id ??
                                'usr-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim().isEmpty
                                ? 'New Customer'
                                : nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            address: addrCtrl.text.trim(),
                            role: role,
                            status: status,
                            ordersCount: existing?.ordersCount ?? 0,
                            totalSpent: existing?.totalSpent ?? 0.0,
                            createdAt: existing?.createdAt ?? DateTime.now(),
                          );
                          Navigator.of(ctx).pop();
                          await controller.saveUserCustomer(
                            record,
                            password: isNew ? pwCtrl.text.trim() : null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                        ),
                        child: Text(isNew ? 'Create Account' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section 9.8: Send Direct In-App Notification to Customer
  Future<void> _showSendNotificationDialog(
    BuildContext context,
    AdminUserCustomer user,
  ) async {
    final titleCtrl =
        TextEditingController(text: 'Special Update from SETEC Store');
    final bodyCtrl = TextEditingController(
      text: 'Hi ${user.name}, thank you for shopping with SETEC eCommerce!',
    );
    String type = 'order_status';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Send Notification to ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Message Body *'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.sendNotification(
                userId: user.id,
                targetLabel: user.name,
                type: type,
                title: titleCtrl.text.trim(),
                body: bodyCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(110, 38)),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }
}
