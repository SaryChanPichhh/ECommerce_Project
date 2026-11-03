import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/admin_models.dart';
import '../controllers/admin_dashboard_controller.dart';

/// Implements Section 9.1 (Categories), 9.2 (Stores), 9.3 (Products & Variants),
/// and 9.4 (Tags) Control Management Web-UI.
class AdminProductsView extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminProductsView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subTab = controller.productSectionTabIndex.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Sub-Navigation Bar: Products | Categories | Merchant Stores | Discovery Tags
          Container(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSubTabChip(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products (${controller.products.length})',
                        index: 0,
                      ),
                      const SizedBox(width: 8),
                      _buildSubTabChip(
                        icon: Icons.category_outlined,
                        label: 'Categories (${controller.categories.length})',
                        index: 1,
                      ),
                      const SizedBox(width: 8),
                      _buildSubTabChip(
                        icon: Icons.storefront_outlined,
                        label: 'Stores (${controller.stores.length})',
                        index: 2,
                      ),
                      const SizedBox(width: 8),
                      _buildSubTabChip(
                        icon: Icons.sell_outlined,
                        label: 'Tags (${controller.tags.length})',
                        index: 3,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (subTab == 0)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showProductFormDialog(context, existing: null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      )
                    else if (subTab == 1)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showCategoryFormDialog(context, existing: null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Category'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      )
                    else if (subTab == 2)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showStoreFormDialog(context, existing: null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Register Store'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _showTagFormDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Tag'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (subTab == 0)
            _buildProductsCatalogCard(context)
          else if (subTab == 1)
            _buildCategoriesTableCard(context)
          else if (subTab == 2)
            _buildStoresTableCard(context)
          else
            _buildTagsTableCard(context),
        ],
      );
    });
  }

  Widget _buildSubTabChip({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = controller.productSectionTabIndex.value == index;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : const Color(0xFF475569),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFFF1F5F9),
      showCheckmark: false,
      onSelected: (_) => controller.productSectionTabIndex.value = index,
    );
  }

  // ──────────────────────────────────────────────────────────
  // Tab 0: Products & Variants Catalog (/api/v1/admin/products/)
  // ──────────────────────────────────────────────────────────
  Widget _buildProductsCatalogCard(BuildContext context) {
    final items = controller.filteredProducts;

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
            'Product Catalog & SKU Inventory',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Manage products, pricing, stock levels, and SKU variants',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => controller.productSearchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Search product name, SKU, store...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip('All', 'all'),
                const SizedBox(width: 6),
                _buildStatusFilterChip('Active', 'active'),
                const SizedBox(width: 6),
                _buildStatusFilterChip('Draft', 'draft'),
                const SizedBox(width: 6),
                _buildStatusFilterChip('Archived', 'archived'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No products found in catalog',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...items.map((prod) => _buildMobileProductCard(context, prod)),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String status) {
    final selected = controller.productStatusFilter.value == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFFF1F5F9),
      showCheckmark: false,
      onSelected: (_) => controller.productStatusFilter.value = status,
    );
  }

  Widget _buildMobileProductCard(BuildContext context, AdminProduct prod) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.white,
                  child: prod.imageUrl != null && prod.imageUrl!.isNotEmpty
                      ? Image.network(
                          prod.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.inventory_2_outlined,
                            size: 24,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          size: 24,
                          color: Color(0xFF64748B),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prod.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildProductStatusPill(prod.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prod.categoryName} • ${prod.storeName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${prod.basePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          'SKU: ${prod.sku}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showVariantsDialog(context, prod),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${prod.totalStock} in stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: prod.totalStock > 0
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${prod.variants.length} SKUs',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Manage Variants & Options',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.style_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: () => _showVariantsDialog(context, prod),
                  ),
                  IconButton(
                    tooltip: 'Edit Product',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                    onPressed: () => _showProductFormDialog(
                      context,
                      existing: prod,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete Product',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    onPressed: () => controller.deleteProduct(prod.id),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Tab 1: Categories Management (/api/v1/admin/categories/)
  // ──────────────────────────────────────────────────────────
  Widget _buildCategoriesTableCard(BuildContext context) {
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
            'Admin Categories',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (controller.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No categories found',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...controller.categories.map((cat) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Slug: ${cat.slug} • Order: ${cat.sortOrder}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildProductStatusPill(cat.status),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showCategoryFormDialog(
                        context,
                        existing: cat,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                      onPressed: () => controller.deleteCategory(cat.id),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Tab 2: Stores Management (/api/v1/admin/stores/)
  // ──────────────────────────────────────────────────────────
  Widget _buildStoresTableCard(BuildContext context) {
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
            'Merchant Stores',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (controller.stores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No stores found',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...controller.stores.map((st) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                        Expanded(
                          child: Text(
                            st.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildProductStatusPill(st.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slug: ${st.slug} • ⭐ ${st.ratingAverage.toStringAsFixed(1)} (${st.ratingCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if ((st.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        st.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () =>
                              _showStoreFormDialog(context, existing: st),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFDC2626),
                          ),
                          onPressed: () => controller.deleteStore(st.id),
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

  // ──────────────────────────────────────────────────────────
  // Tab 3: Tags Management (/api/v1/admin/tags/)
  // ──────────────────────────────────────────────────────────
  Widget _buildTagsTableCard(BuildContext context) {
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
          const Text(
            'Product Discovery Tags (/api/v1/admin/tags/)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.tags.map((tag) {
              return Chip(
                avatar: const Icon(
                  Icons.sell_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                label: Text(
                  '${tag.name} (${tag.slug})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => controller.deleteTag(tag.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Dialogs: Create/Edit Product, Variants, Category, Store, Tag
  // ──────────────────────────────────────────────────────────
  Future<void> _showProductFormDialog(
    BuildContext context, {
    required AdminProduct? existing,
  }) async {
    final isNew = existing == null;
    final dialogFormKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl = TextEditingController(
      text: existing?.sku ??
          'SKU-${DateTime.now().millisecondsSinceEpoch % 1000000}',
    );
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.basePrice.toStringAsFixed(2) : '49.99',
    );
    final stockCtrl = TextEditingController(
      text: '${existing?.stockQuantity ?? 20}',
    );
    final imgCtrl = TextEditingController(
      text: existing?.imageUrl ??
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7',
    );
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String status = existing?.status ?? 'active';
    bool isSaving = false;

    final availableCategories = controller.categories.toList();
    final availableStores = controller.stores.toList();

    String selectedCatId = existing?.categoryId ??
        (availableCategories.isNotEmpty ? availableCategories.first.id : '');
    String selectedStoreId = existing?.storeId ??
        (availableStores.isNotEmpty ? availableStores.first.id : '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNew ? 'Create New Product' : 'Edit Product',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Product Name *'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Product name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: skuCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SKU *',
                              hintText: 'e.g. KB-MECH-01',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'SKU is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: priceCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Base Price (USD) *',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Price is required';
                              }
                              final val = double.tryParse(v.trim());
                              if (val == null || val <= 0) {
                                return 'Enter a valid price > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                            ),
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                final n = int.tryParse(v.trim());
                                if (n == null || n < 0) {
                                  return 'Enter a valid stock number';
                                }
                              }
                              return null;
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
                                child: Text('Active (Approved)', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'draft',
                                child: Text('Draft (Pending)', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'archived',
                                child: Text('Archived', overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => status = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: availableCategories.any((c) => c.id == selectedCatId)
                          ? selectedCatId
                          : availableCategories.first.id,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category *'),
                      items: availableCategories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedCatId = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: availableStores.any((s) => s.id == selectedStoreId)
                          ? selectedStoreId
                          : availableStores.first.id,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Merchant Store *'),
                      items: availableStores
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedStoreId = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Primary Image URL',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(95, 40),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!dialogFormKey.currentState!.validate()) {
                                    return;
                                  }
                                  setDialogState(() => isSaving = true);

                                  final name = nameCtrl.text.trim().isEmpty
                                      ? 'New Product'
                                      : nameCtrl.text.trim();
                                  final slug = name
                                      .toLowerCase()
                                      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                                      .replaceAll(RegExp(r'^-|-$'), '');
                                  final catObj = availableCategories.firstWhereOrNull(
                                    (c) => c.id == selectedCatId,
                                  );
                                  final storeObj = availableStores.firstWhereOrNull(
                                    (s) => s.id == selectedStoreId,
                                  );

                                  final skuText = skuCtrl.text.trim().isNotEmpty
                                      ? skuCtrl.text.trim()
                                      : 'SKU-${DateTime.now().millisecondsSinceEpoch % 1000000}';

                                  final prod = AdminProduct(
                                    id: existing?.id ??
                                        'prod-${DateTime.now().millisecondsSinceEpoch}',
                                    storeId: selectedStoreId,
                                    storeName:
                                        storeObj?.name ?? 'Kutuku Official Store',
                                    categoryId: selectedCatId,
                                    categoryName: catObj?.name ?? 'Electronics',
                                    name: name,
                                    slug: slug,
                                    sku: skuText,
                                    description: descCtrl.text.trim(),
                                    basePrice:
                                        double.tryParse(priceCtrl.text.trim()) ?? 49.99,
                                    stockQuantity:
                                        int.tryParse(stockCtrl.text.trim()) ?? 20,
                                    imageUrl: imgCtrl.text.trim(),
                                    status: status,
                                    variants: existing?.variants ?? const [],
                                    createdAt: existing?.createdAt ?? DateTime.now(),
                                  );

                                  try {
                                    await controller.saveProduct(prod, isNew: isNew);
                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                    }
                                  } catch (e) {
                                    setDialogState(() => isSaving = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(135, 40),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isNew ? 'Create Product' : 'Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section 9.3 Variants & Options Manager Dialog
  Future<void> _showVariantsDialog(
    BuildContext context,
    AdminProduct product,
  ) async {
    final nameCtrl = TextEditingController(text: 'Black / XL');
    final skuCtrl = TextEditingController(text: '${product.sku}-BLK-XL');
    final priceCtrl =
        TextEditingController(text: product.basePrice.toStringAsFixed(2));
    final stockCtrl = TextEditingController(text: '15');

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              final latestProduct = controller.products.firstWhere(
                (p) => p.id == product.id,
                orElse: () => product,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU Variants & Options — ${latestProduct.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Endpoint: /api/v1/admin/product/variants/',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  if (latestProduct.variants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No SKU variants registered yet.'),
                    )
                  else
                    ...latestProduct.variants.map((v) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            '${v.name}  •  \$${v.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'SKU: ${v.sku}  |  Stock: ${v.stockQuantity} units  |  Options: ${v.options.map((o) => "${o.name}: ${o.value}").join(", ")}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFDC2626),
                            ),
                            onPressed: () =>
                                controller.removeVariantFromProduct(
                              latestProduct.id,
                              v.id,
                            ),
                          ),
                        ),
                      );
                    }),
                  const Divider(height: 24),
                  const Text(
                    'Add New Variant SKU',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Variant Title (e.g. Black / XL)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: skuCtrl,
                          decoration: const InputDecoration(labelText: 'SKU'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(labelText: 'Price'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: stockCtrl,
                          decoration: const InputDecoration(labelText: 'Stock'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final v = AdminProductVariant(
                            id: 'vrn-${DateTime.now().millisecondsSinceEpoch}',
                            productId: latestProduct.id,
                            name: nameCtrl.text.trim(),
                            sku: skuCtrl.text.trim(),
                            price: double.tryParse(priceCtrl.text.trim()) ??
                                latestProduct.basePrice,
                            stockQuantity:
                                int.tryParse(stockCtrl.text.trim()) ?? 10,
                            status: 'active',
                          );
                          await controller.addVariantToProduct(v);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Variant'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 38),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryFormDialog(
    BuildContext context, {
    required AdminCategory? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final slugCtrl = TextEditingController(text: existing?.slug ?? '');
    String status = existing?.status ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Create Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Category Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slugCtrl,
              decoration: const InputDecoration(labelText: 'Slug *'),
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
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final slug = slugCtrl.text.trim().isNotEmpty
                  ? slugCtrl.text.trim()
                  : name.toLowerCase().replaceAll(' ', '-');
              Navigator.of(ctx).pop();
              await controller.saveCategory(
                AdminCategory(
                  id: existing?.id ??
                      'cat-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  slug: slug,
                  status: status,
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 38)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showStoreFormDialog(
    BuildContext context, {
    required AdminStore? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final slugCtrl = TextEditingController(text: existing?.slug ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Register Store' : 'Edit Store'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Store Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slugCtrl,
              decoration: const InputDecoration(labelText: 'Slug *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
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
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final slug = slugCtrl.text.trim().isNotEmpty
                  ? slugCtrl.text.trim()
                  : name.toLowerCase().replaceAll(' ', '-');
              Navigator.of(ctx).pop();
              await controller.saveStore(
                AdminStore(
                  id: existing?.id ??
                      'store-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  slug: slug,
                  description: descCtrl.text.trim(),
                  status: existing?.status ?? 'active',
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 38)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTagFormDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Discovery Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tag Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slugCtrl,
              decoration: const InputDecoration(labelText: 'Slug *'),
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
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final slug = slugCtrl.text.trim().isNotEmpty
                  ? slugCtrl.text.trim()
                  : name.toLowerCase().replaceAll(' ', '-');
              Navigator.of(ctx).pop();
              await controller.createTag(name, slug);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 38)),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStatusPill(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    String label;

    switch (s) {
      case 'active':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'Active (Approved)';
        break;
      case 'draft':
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'Pending Approval';
        break;
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'Archived';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
