import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({String? parentId});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CategoryModel>> getCategories({String? parentId}) async {
    if (parentId != null && parentId.isNotEmpty) {
      final response = await _apiClient.get(
        ApiConstants.publicCategories,
        queryParameters: {'parent_id': parentId},
      );
      return _extractCategoryList(response.data);
    }

    // Fetch full hierarchical tree so both top-level and child categories
    // are visible across storefront carousels and filters.
    try {
      final treeResponse = await _apiClient.get(ApiConstants.publicCategoriesTree);
      final flattened = _flattenTree(treeResponse.data);
      if (flattened.isNotEmpty) {
        return flattened;
      }
    } catch (_) {
      // Fallback to flat publicCategories endpoint below.
    }

    final response = await _apiClient.get(ApiConstants.publicCategories);
    return _extractCategoryList(response.data);
  }

  List<CategoryModel> _extractCategoryList(dynamic data) {
    final List<dynamic> items;
    if (data is Map<String, dynamic>) {
      items = data['data'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  List<CategoryModel> _flattenTree(dynamic data) {
    final List<dynamic> roots;
    if (data is Map<String, dynamic>) {
      roots = data['data'] as List<dynamic>? ?? [];
    } else if (data is List) {
      roots = data;
    } else {
      roots = [];
    }

    final seenIds = <String>{};
    final result = <CategoryModel>[];

    void walk(dynamic node) {
      if (node is! Map) return;
      final map = Map<String, dynamic>.from(node);
      final model = CategoryModel.fromJson(map);
      if (model.id.isNotEmpty && seenIds.add(model.id)) {
        result.add(model);
      }
      final children = map['children'];
      if (children is List) {
        for (final child in children) {
          walk(child);
        }
      }
    }

    for (final root in roots) {
      walk(root);
    }
    return result;
  }
}
