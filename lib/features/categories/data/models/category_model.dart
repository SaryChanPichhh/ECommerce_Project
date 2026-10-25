import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.slug,
    super.parentId,
    super.iconUrl,
    super.imageUrl,
    super.sortOrder,
    super.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      parentId: json['parent_id'] as String?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: json['sort_order'] is num
          ? (json['sort_order'] as num).toInt()
          : int.tryParse(json['sort_order']?.toString() ?? ''),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'parent_id': parentId,
      'icon_url': iconUrl,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'status': status,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      parentId: category.parentId,
      iconUrl: category.iconUrl,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      status: category.status,
    );
  }
}
