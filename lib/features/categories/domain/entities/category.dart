class Category {
  final String id;
  final String name;
  final String? slug;
  final String? parentId;
  final String? iconUrl;
  final String? imageUrl;
  final int? sortOrder;
  final String? status;

  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
    this.iconUrl,
    this.imageUrl,
    this.sortOrder,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
