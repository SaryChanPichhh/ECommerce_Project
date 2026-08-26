import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? search,
  });
  Future<ProductModel> getProduct(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final List<ProductModel> products = [
    ProductModel(
      id: "1",
      name: 'iPhone 15 Pro',
      description: 'Apple iPhone 15 Pro with A17 Pro chip and titanium design.',
      price: 999.99,
      quantity: 10,
      category: 'Smartphone',
      imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc',
      isActive: true,
      createdAt: DateTime(2026, 1, 10),
      updatedAt: DateTime(2026, 8, 20),
    ),
    ProductModel(
      id: "2",
      name: 'Samsung Galaxy S25',
      description:
          'Samsung Galaxy S25 with powerful performance and AMOLED display.',
      price: 899.99,
      quantity: 15,
      category: 'Smartphone',
      imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c',
      isActive: true,
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 8, 18),
    ),
    ProductModel(
      id: "3",
      name: 'MacBook Air M3',
      description: 'Lightweight MacBook Air powered by Apple M3 chip.',
      price: 1099.00,
      quantity: 8,
      category: 'Laptop',
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
      isActive: true,
      createdAt: DateTime(2026, 2, 5),
      updatedAt: DateTime(2026, 8, 15),
    ),
    ProductModel(
      id: "4",
      name: 'Dell XPS 15',
      description: 'Premium Windows laptop with a high-resolution display.',
      price: 1499.99,
      quantity: 5,
      category: 'Laptop',
      imageUrl: 'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6',
      isActive: true,
      createdAt: DateTime(2026, 2, 12),
      updatedAt: DateTime(2026, 8, 12),
    ),
    ProductModel(
      id: "5",
      name: 'AirPods Pro 2',
      description: 'Wireless earbuds with active noise cancellation.',
      price: 249.99,
      quantity: 25,
      category: 'Audio',
      imageUrl: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434',
      isActive: true,
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 8, 10),
    ),
    ProductModel(
      id: "6",
      name: 'Sony WH-1000XM5',
      description:
          'Premium wireless headphones with industry-leading noise cancellation.',
      price: 399.99,
      quantity: 12,
      category: 'Audio',
      imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb',
      isActive: true,
      createdAt: DateTime(2026, 3, 8),
      updatedAt: DateTime(2026, 8, 8),
    ),
    ProductModel(
      id: "7",
      name: 'Apple Watch Series 10',
      description:
          'Smartwatch with health, fitness, and communication features.',
      price: 429.00,
      quantity: 7,
      category: 'Smartwatch',
      imageUrl: 'https://images.unsplash.com/photo-1551816230-ef5deaed4a26',
      isActive: true,
      createdAt: DateTime(2026, 4, 2),
      updatedAt: DateTime(2026, 8, 5),
    ),
    ProductModel(
      id: "8",
      name: 'Logitech MX Master 3S',
      description: 'Advanced wireless mouse designed for productivity.',
      price: 99.99,
      quantity: 30,
      category: 'Accessories',
      imageUrl: 'https://images.unsplash.com/photo-1527814050087-3793815479db',
      isActive: true,
      createdAt: DateTime(2026, 4, 10),
      updatedAt: DateTime(2026, 8, 3),
    ),
    ProductModel(
      id: "9",
      name: 'Mechanical Keyboard',
      description: 'RGB mechanical keyboard with tactile switches.',
      price: 129.99,
      quantity: 20,
      category: 'Accessories',
      imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3',
      isActive: true,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 8, 1),
    ),
    ProductModel(
      id: "10",
      name: 'iPad Air M3',
      description:
          'Powerful and lightweight tablet for work and entertainment.',
      price: 599.00,
      quantity: 10,
      category: 'Tablet',
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0',
      isActive: false,
      createdAt: DateTime(2026, 5, 15),
      updatedAt: DateTime(2026, 7, 30),
    ),
  ];

  @override
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get(
        '/products',
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> items;

      if (data is Map<String, dynamic>) {
        items = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      return items
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      return products;
    }
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      final data = response.data;
      final productData = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return ProductModel.fromJson(productData);
    } on AppException {
      final matchedProducts = products.where((p) => p.id == id);
      if (matchedProducts.isNotEmpty) {
        return matchedProducts.first;
      }
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/products', data: data);
    final responseData = response.data;
    final productData =
        responseData is Map<String, dynamic> && responseData.containsKey('data')
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;
    return ProductModel.fromJson(productData);
  }

  @override
  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put('/products/$id', data: data);
    final responseData = response.data;
    final productData =
        responseData is Map<String, dynamic> && responseData.containsKey('data')
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;
    return ProductModel.fromJson(productData);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('/products/$id');
  }
}
