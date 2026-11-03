double _toDouble(dynamic val, [double fallback = 0.0]) {
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? fallback;
  return fallback;
}

int _toInt(dynamic val, [int fallback = 0]) {
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? fallback;
  return fallback;
}

DateTime? _toDate(dynamic val) {
  if (val is DateTime) return val;
  if (val is String && val.isNotEmpty) return DateTime.tryParse(val);
  return null;
}

/// Section 9.1: Admin Category Model
class AdminCategory {
  final String id;
  final String? parentId;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? imageUrl;
  final int sortOrder;
  final String status; // 'active' | 'inactive'

  const AdminCategory({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.imageUrl,
    this.sortOrder = 0,
    this.status = 'active',
  });

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      name: json['name']?.toString() ?? 'Category',
      slug: json['slug']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString(),
      imageUrl: json['image_url']?.toString(),
      sortOrder: _toInt(json['sort_order']),
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'parent_id': parentId,
        if (iconUrl != null && iconUrl!.isNotEmpty) 'icon_url': iconUrl,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
        'sort_order': sortOrder,
        'status': status,
      };

  AdminCategory copyWith({
    String? id,
    String? parentId,
    String? name,
    String? slug,
    String? iconUrl,
    String? imageUrl,
    int? sortOrder,
    String? status,
  }) {
    return AdminCategory(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
    );
  }
}

/// Section 9.2: Admin Store Model
class AdminStore {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String status; // 'active' | 'pending' | 'suspended'
  final double ratingAverage;
  final int ratingCount;

  const AdminStore({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.status = 'active',
    this.ratingAverage = 4.8,
    this.ratingCount = 0,
  });

  factory AdminStore.fromJson(Map<String, dynamic> json) {
    return AdminStore(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Store',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      status: json['status']?.toString() ?? 'active',
      ratingAverage: _toDouble(json['rating_average'], 4.8),
      ratingCount: _toInt(json['rating_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        if (description != null) 'description': description,
        if (logoUrl != null && logoUrl!.isNotEmpty) 'logo_url': logoUrl,
        if (bannerUrl != null && bannerUrl!.isNotEmpty) 'banner_url': bannerUrl,
        'status': status,
      };

  AdminStore copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? status,
    double? ratingAverage,
    int? ratingCount,
  }) {
    return AdminStore(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      status: status ?? this.status,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

/// Section 9.4: Admin Tag Model
class AdminTag {
  final String id;
  final String name;
  final String slug;

  const AdminTag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AdminTag.fromJson(Map<String, dynamic> json) {
    return AdminTag(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
      };

  AdminTag copyWith({
    String? id,
    String? name,
    String? slug,
  }) {
    return AdminTag(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }
}

/// Section 9.3: Admin Product Variant Option Model
class AdminVariantOption {
  final String id;
  final String? variantId;
  final String name;
  final String value;

  const AdminVariantOption({
    this.id = '',
    this.variantId,
    required this.name,
    required this.value,
  });

  factory AdminVariantOption.fromJson(Map<String, dynamic> json) {
    return AdminVariantOption(
      id: json['id']?.toString() ?? '',
      variantId: json['variant_id']?.toString(),
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (variantId != null && variantId!.isNotEmpty) 'variant_id': variantId,
        'name': name,
        'value': value,
      };

  AdminVariantOption copyWith({
    String? id,
    String? variantId,
    String? name,
    String? value,
  }) {
    return AdminVariantOption(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

/// Section 9.3: Admin Product Variant Model
class AdminProductVariant {
  final String id;
  final String productId;
  final String name;
  final String sku;
  final double price;
  final int stockQuantity;
  final String status; // 'active' | 'inactive' | 'out_of_stock'
  final List<AdminVariantOption> options;

  const AdminProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    this.status = 'active',
    this.options = const [],
  });

  factory AdminProductVariant.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] is List
        ? (json['options'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AdminVariantOption.fromJson)
            .toList()
        : <AdminVariantOption>[];
    return AdminProductVariant(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: _toDouble(json['price']),
      stockQuantity: _toInt(json['stock_quantity']),
      status: json['status']?.toString() ?? 'active',
      options: opts,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'sku': sku,
        'price': price,
        'stock_quantity': stockQuantity,
        'status': status,
        'options': options
            .map((o) => {'name': o.name, 'value': o.value})
            .toList(),
      };

  AdminProductVariant copyWith({
    String? id,
    String? productId,
    String? name,
    String? sku,
    double? price,
    int? stockQuantity,
    String? status,
    List<AdminVariantOption>? options,
  }) {
    return AdminProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      options: options ?? this.options,
    );
  }
}

/// Section 9.3: Admin Product Model (Supports Product Catalog & Approved-Product Workflow)
class AdminProduct {
  final String id;
  final String storeId;
  final String storeName;
  final String categoryId;
  final String categoryName;
  final String name;
  final String slug;
  final String sku;
  final String description;
  final double basePrice;
  final double? compareAtPrice;
  final String currency;
  final int stockQuantity;
  final String? imageUrl;
  final String status; // 'active' (approved), 'draft' (pending approval), 'archived' (rejected/hidden)
  final double ratingAverage;
  final int ratingCount;
  final List<AdminProductVariant> variants;
  final DateTime? createdAt;

  const AdminProduct({
    required this.id,
    required this.storeId,
    this.storeName = 'Kutuku Official Store',
    required this.categoryId,
    this.categoryName = 'Electronics',
    required this.name,
    required this.slug,
    required this.sku,
    this.description = '',
    required this.basePrice,
    this.compareAtPrice,
    this.currency = 'USD',
    this.stockQuantity = 0,
    this.imageUrl,
    this.status = 'active',
    this.ratingAverage = 4.7,
    this.ratingCount = 12,
    this.variants = const [],
    this.createdAt,
  });

  bool get isApproved => status.toLowerCase() == 'active';
  bool get isPendingApproval =>
      status.toLowerCase() == 'draft' || status.toLowerCase() == 'pending';
  bool get isArchived =>
      status.toLowerCase() == 'archived' ||
      status.toLowerCase() == 'inactive' ||
      status.toLowerCase() == 'rejected';

  int get totalStock {
    if (variants.isNotEmpty) {
      return variants.fold<int>(0, (sum, v) => sum + v.stockQuantity);
    }
    return stockQuantity;
  }

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    final variantsList = json['variants'] is List
        ? (json['variants'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AdminProductVariant.fromJson)
            .toList()
        : <AdminProductVariant>[];

    String storeId = json['store_id']?.toString() ?? 'str-000005';
    String storeName = json['store_name']?.toString() ?? 'Prime Gadgetry';
    if (json['store'] is Map) {
      final s = json['store'] as Map;
      storeId = s['id']?.toString() ?? storeId;
      storeName = s['name']?.toString() ?? storeName;
    }

    String categoryId = json['category_id']?.toString() ?? 'cat-000001';
    String categoryName = json['category_name']?.toString() ??
        json['category']?.toString() ??
        'Consumer Electronics';
    if (json['category'] is Map) {
      final c = json['category'] as Map;
      categoryId = c['id']?.toString() ?? categoryId;
      categoryName = c['name']?.toString() ?? categoryName;
    }

    final rawName = json['name']?.toString() ?? 'Product';
    final rawSlug = json['slug']?.toString() ??
        rawName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');

    return AdminProduct(
      id: json['id']?.toString() ?? '',
      storeId: storeId,
      storeName: storeName,
      categoryId: categoryId,
      categoryName: categoryName,
      name: rawName,
      slug: rawSlug,
      sku: json['sku']?.toString() ?? 'SKU-001',
      description: json['description']?.toString() ?? '',
      basePrice: _toDouble(json['base_price'] ?? json['price']),
      compareAtPrice: json['compare_at_price'] != null
          ? _toDouble(json['compare_at_price'])
          : null,
      currency: json['currency']?.toString() ?? 'USD',
      stockQuantity: _toInt(json['stock_quantity'] ?? json['quantity'], 15),
      imageUrl: json['primary_image_url']?.toString() ??
          json['image_url']?.toString(),
      status: json['status']?.toString() ??
          (json['is_active'] == false ? 'draft' : 'active'),
      ratingAverage: _toDouble(json['rating_average'], 4.7),
      ratingCount: _toInt(json['rating_count'], 8),
      variants: variantsList,
      createdAt: _toDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'category_id': categoryId,
        'name': name,
        'slug': slug,
        'description': description,
        'sku': sku,
        'base_price': basePrice.toStringAsFixed(2),
        if (compareAtPrice != null)
          'compare_at_price': compareAtPrice!.toStringAsFixed(2),
        'currency': currency,
        'status': status,
        if (imageUrl != null && imageUrl!.isNotEmpty)
          'primary_image_url': imageUrl,
      };

  AdminProduct copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? categoryId,
    String? categoryName,
    String? name,
    String? slug,
    String? sku,
    String? description,
    double? basePrice,
    double? compareAtPrice,
    String? currency,
    int? stockQuantity,
    String? imageUrl,
    String? status,
    double? ratingAverage,
    int? ratingCount,
    List<AdminProductVariant>? variants,
    DateTime? createdAt,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      currency: currency ?? this.currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      variants: variants ?? this.variants,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User & Customer Control Management Record
class AdminUserCustomer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'admin' | 'support'
  final String status; // 'active' | 'inactive' | 'blocked'
  final String address;
  final int ordersCount;
  final double totalSpent;
  final String? avatarUrl;
  final DateTime? createdAt;

  const AdminUserCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.status = 'active',
    this.address = 'Phnom Penh, Cambodia',
    this.ordersCount = 0,
    this.totalSpent = 0.0,
    this.avatarUrl,
    this.createdAt,
  });

  factory AdminUserCustomer.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final combined = '$firstName $lastName'.trim();
    final name = (json['name']?.toString() ?? '').trim().isNotEmpty
        ? json['name'].toString()
        : (combined.isNotEmpty
            ? combined
            : (json['email']?.toString().split('@').first ?? 'Customer'));

    return AdminUserCustomer(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: name,
      email: json['email']?.toString() ?? '',
      phone: json['phone_number']?.toString() ??
          json['phone']?.toString() ??
          '+855 12 345 678',
      role: json['role']?.toString() ?? 'customer',
      status: json['status']?.toString() ?? 'active',
      address: json['address']?.toString() ?? 'Phnom Penh, Cambodia',
      ordersCount: _toInt(json['orders_count']),
      totalSpent: _toDouble(json['total_spent']),
      avatarUrl: json['avatar_url']?.toString(),
      createdAt: _toDate(json['created_at']),
    );
  }

  AdminUserCustomer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? address,
    int? ordersCount,
    double? totalSpent,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return AdminUserCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      address: address ?? this.address,
      ordersCount: ordersCount ?? this.ordersCount,
      totalSpent: totalSpent ?? this.totalSpent,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Section 9.7: Admin Review Moderation Model
class AdminReview {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String customerName;
  final int rating;
  final String comment;
  final String status; // 'published' | 'hidden' | 'flagged'
  final DateTime? createdAt;

  const AdminReview({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.status = 'published',
    this.createdAt,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    return AdminReview(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Product',
      userId: json['user_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ??
          json['user_name']?.toString() ??
          'Verified Customer',
      rating: _toInt(json['rating'], 5),
      comment: json['comment']?.toString() ?? json['body']?.toString() ?? '',
      status: json['status']?.toString() ?? 'published',
      createdAt: _toDate(json['created_at']),
    );
  }

  AdminReview copyWith({
    String? status,
    String? comment,
    int? rating,
  }) {
    return AdminReview(
      id: id,
      productId: productId,
      productName: productName,
      userId: userId,
      customerName: customerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

/// Section 9.9: Admin Support Ticket & Message Models
class AdminTicketMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String body;
  final DateTime? createdAt;

  const AdminTicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    this.senderName = 'Admin Support',
    this.isAdmin = true,
    required this.body,
    this.createdAt,
  });

  factory AdminTicketMessage.fromJson(Map<String, dynamic> json) {
    final sId = json['sender_id']?.toString() ?? '';
    return AdminTicketMessage(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      senderId: sId,
      senderName: json['sender_name']?.toString() ??
          (sId.contains('admin') ? 'SETEC Admin' : 'Customer'),
      isAdmin: json['is_admin'] == true || sId.contains('admin'),
      body: json['body']?.toString() ?? '',
      createdAt: _toDate(json['created_at']),
    );
  }
}

class AdminSupportTicket {
  final String id;
  final String userId;
  final String customerName;
  final String subject;
  final String status; // 'open' | 'in_progress' | 'waiting_customer' | 'resolved' | 'closed'
  final String priority; // 'low' | 'normal' | 'high' | 'urgent'
  final String? assignedTo;
  final DateTime? createdAt;
  final List<AdminTicketMessage> messages;

  const AdminSupportTicket({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.subject,
    this.status = 'open',
    this.priority = 'normal',
    this.assignedTo,
    this.createdAt,
    this.messages = const [],
  });

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'] is List
        ? (json['messages'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AdminTicketMessage.fromJson)
            .toList()
        : <AdminTicketMessage>[];
    return AdminSupportTicket(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      subject: json['subject']?.toString() ?? 'Support Inquiry',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'normal',
      assignedTo: json['assigned_to']?.toString(),
      createdAt: _toDate(json['created_at']),
      messages: msgs,
    );
  }

  AdminSupportTicket copyWith({
    String? status,
    String? priority,
    String? assignedTo,
    List<AdminTicketMessage>? messages,
  }) {
    return AdminSupportTicket(
      id: id,
      userId: userId,
      customerName: customerName,
      subject: subject,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }
}

/// Section 9.8 & 8.11: Admin Broadcast & In-App Notification Model
class AdminBroadcastNotification {
  final String id;
  final String userId;
  final String targetLabel;
  final String type; // 'order_status' | 'promotion' | 'system'
  final String title;
  final String body;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final String status; // 'unread' | 'read'
  final DateTime? readAt;
  final DateTime? createdAt;

  const AdminBroadcastNotification({
    required this.id,
    required this.userId,
    this.targetLabel = 'Customer',
    required this.type,
    required this.title,
    required this.body,
    this.actionUrl,
    this.data,
    this.status = 'unread',
    this.readAt,
    this.createdAt,
  });

  factory AdminBroadcastNotification.fromJson(Map<String, dynamic> json) {
    return AdminBroadcastNotification(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      targetLabel: json['target_label']?.toString() ??
          json['user_id']?.toString() ??
          'Customer',
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      actionUrl: json['action_url']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      status: json['status']?.toString() ??
          (json['read_at'] != null ? 'read' : 'unread'),
      readAt: _toDate(json['read_at']),
      createdAt: _toDate(json['created_at']),
    );
  }

  AdminBroadcastNotification copyWith({
    String? status,
    DateTime? readAt,
  }) {
    return AdminBroadcastNotification(
      id: id,
      userId: userId,
      targetLabel: targetLabel,
      type: type,
      title: title,
      body: body,
      actionUrl: actionUrl,
      data: data,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}

/// Section 9.10: Admin Legal Document Model
class AdminLegalDocument {
  final String id;
  final String type; // 'terms' | 'privacy' | 'refund' | 'shipping'
  final String title;
  final String version;
  final String content;
  final String status; // 'published' | 'draft' | 'archived'
  final DateTime? publishedAt;

  const AdminLegalDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.version,
    required this.content,
    this.status = 'published',
    this.publishedAt,
  });

  factory AdminLegalDocument.fromJson(Map<String, dynamic> json) {
    return AdminLegalDocument(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'terms',
      title: json['title']?.toString() ?? '',
      version: json['version']?.toString() ?? '1.0',
      content: json['content']?.toString() ?? '',
      status: json['status']?.toString() ?? 'published',
      publishedAt: _toDate(json['published_at'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'version': version,
        'content': content,
        'status': status,
        'published_at':
            (publishedAt ?? DateTime.now()).toUtc().toIso8601String(),
      };

  AdminLegalDocument copyWith({
    String? id,
    String? type,
    String? title,
    String? version,
    String? content,
    String? status,
    DateTime? publishedAt,
  }) {
    return AdminLegalDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      version: version ?? this.version,
      content: content ?? this.content,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

/// Section 8.10: Admin / Customer Chat Message Model (Allowed Roles: customer, admin)
class AdminChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' | 'admin' | 'support'
  final bool isAdmin;
  final String messageType; // 'text' | 'image' | 'file'
  final String body;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AdminChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName = 'Admin',
    this.senderRole = 'admin',
    this.isAdmin = true,
    this.messageType = 'text',
    required this.body,
    this.attachmentUrl,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  factory AdminChatMessage.fromJson(Map<String, dynamic> json) {
    final sId = json['sender_id']?.toString() ?? '';
    final role = json['sender_role']?.toString() ??
        (sId.contains('admin') ? 'admin' : 'customer');
    final isAdm = json['is_admin'] == true ||
        role == 'admin' ||
        sId.contains('admin');
    final rAt = _toDate(json['read_at']);
    return AdminChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: sId,
      senderName: json['sender_name']?.toString() ??
          (isAdm ? 'SETEC Admin' : 'Customer'),
      senderRole: role,
      isAdmin: isAdm,
      messageType: json['message_type']?.toString() ?? 'text',
      body: json['body']?.toString() ?? '',
      attachmentUrl: json['attachment_url']?.toString(),
      isRead: json['is_read'] == true || rAt != null,
      readAt: rAt,
      createdAt: _toDate(json['created_at']),
    );
  }

  AdminChatMessage copyWith({
    String? body,
    bool? isRead,
    DateTime? readAt,
  }) {
    return AdminChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      isAdmin: isAdmin,
      messageType: messageType,
      body: body ?? this.body,
      attachmentUrl: attachmentUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}

/// Section 8.10: Admin / Customer Conversation Model (Allowed Roles: customer, admin)
class AdminConversation {
  final String id;
  final String customerId;
  final String customerName;
  final String? storeId;
  final String storeName;
  final String? orderId;
  final String status; // 'open' | 'closed'
  final DateTime? lastMessageAt;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final List<AdminChatMessage> messages;

  const AdminConversation({
    required this.id,
    required this.customerId,
    this.customerName = 'Customer',
    this.storeId,
    this.storeName = 'Kutuku Official Store',
    this.orderId,
    this.status = 'open',
    this.lastMessageAt,
    this.updatedAt,
    this.createdAt,
    this.messages = const [],
  });

  factory AdminConversation.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'] is List
        ? (json['messages'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AdminChatMessage.fromJson)
            .toList()
        : <AdminChatMessage>[];
    return AdminConversation(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      storeId: json['store_id']?.toString(),
      storeName: json['store_name']?.toString() ?? 'Kutuku Official Store',
      orderId: json['order_id']?.toString(),
      status: json['status']?.toString() ?? 'open',
      lastMessageAt: _toDate(json['last_message_at'] ?? json['updated_at']),
      updatedAt: _toDate(json['updated_at'] ?? json['last_message_at']),
      createdAt: _toDate(json['created_at']),
      messages: msgs,
    );
  }

  AdminConversation copyWith({
    String? status,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
    List<AdminChatMessage>? messages,
  }) {
    return AdminConversation(
      id: id,
      customerId: customerId,
      customerName: customerName,
      storeId: storeId,
      storeName: storeName,
      orderId: orderId,
      status: status ?? this.status,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }
}

/// Section 8.2: Active Device Session Model (Allowed Roles: customer, admin, support)
class AdminDeviceSession {
  final String id;
  final String deviceName;
  final String ipAddress;
  final String userAgent;
  final bool isCurrent;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const AdminDeviceSession({
    required this.id,
    required this.deviceName,
    required this.ipAddress,
    this.userAgent = 'Flutter Web / Chrome',
    this.isCurrent = false,
    this.lastActiveAt,
    this.createdAt,
  });

  factory AdminDeviceSession.fromJson(Map<String, dynamic> json) {
    return AdminDeviceSession(
      id: json['id']?.toString() ?? json['session_id']?.toString() ?? '',
      deviceName: json['device_name']?.toString() ??
          json['device']?.toString() ??
          'Web Admin Browser',
      ipAddress: json['ip_address']?.toString() ?? '127.0.0.1',
      userAgent: json['user_agent']?.toString() ?? 'Flutter Web / Chrome',
      isCurrent: json['is_current'] == true,
      lastActiveAt: _toDate(json['last_active_at'] ?? json['updated_at']),
      createdAt: _toDate(json['created_at']),
    );
  }
}
