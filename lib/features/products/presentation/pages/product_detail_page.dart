import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_products.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? product;
  bool isLoading = true;
  String errorMessage = '';
  int orderAmount = 1;
  List<Product> relatedProducts = [];
  bool isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final productId = Get.parameters['id'] ?? Get.arguments as String?;
    if (productId == null) {
      setState(() {
        errorMessage = 'Product ID not provided';
        isLoading = false;
      });
      return;
    }

    try {
      final useCase = Get.find<GetProductUseCase>();
      final result = await useCase(productId);
      if (mounted) {
        setState(() {
          product = result;
          isLoading = false;
        });
      }
      _loadRelatedProducts(result.category);
    } on Failure catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load product';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRelatedProducts(String? category) async {
    if (!mounted) return;
    setState(() {
      isLoadingRelated = true;
    });
    try {
      final getProducts = Get.find<GetProductsUseCase>();
      final result = await getProducts(limit: 10);
      if (mounted) {
        setState(() {
          relatedProducts = result
              .where(
                (p) =>
                    p.id != product?.id &&
                    (category == null || p.category == category),
              )
              .toList();
          isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingRelated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: _buildBody(),
      bottomNavigationBar: product != null ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    // You can change the background color of the sticky bottom navigation bar here
    final bottomNavColor = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: bottomNavColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    '\$${(product!.price * orderAmount).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(90, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const AppLoading(message: 'Loading product...');
    }

    if (errorMessage.isNotEmpty) {
      return AppError(message: errorMessage, onRetry: _loadProduct);
    }

    if (product == null) {
      return const AppError(message: 'Product not found');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              image: product!.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(product!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product!.imageUrl == null
                ? const Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.lg),

          // First Row: Title, Rating vs Quantity controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Title and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(120 reviews)',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              // Right side: Quantity control and stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: orderAmount > 1
                              ? () => setState(() => orderAmount--)
                              : null,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              size: 20,
                              color: orderAmount > 1
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$orderAmount',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          onTap: orderAmount < product!.quantity
                              ? () => setState(() => orderAmount++)
                              : null,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: orderAmount < product!.quantity
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${product!.quantity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: product!.quantity > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Second Row: Color / Size variants (Dummy data)
          Text(
            'Color',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              _buildColorOption(Colors.black, isSelected: true),
              const SizedBox(width: AppDimensions.sm),
              _buildColorOption(Colors.blue, isSelected: false),
              const SizedBox(width: AppDimensions.sm),
              _buildColorOption(Colors.grey, isSelected: false),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Third Row: Description
          if (product!.description != null &&
              product!.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              product!.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],

          // Fourth Row: Supplier Info
          Text(
            'Supplier',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.storefront, color: Colors.white),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Store',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '99+ Products',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(90, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: const Text('View Shop'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),

          // Related Products Section
          _buildRelatedProducts(),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    if (isLoadingRelated) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Products',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final relatedProduct = relatedProducts[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/products/${relatedProduct.id}',
                    arguments: relatedProduct.id,
                    preventDuplicates: false,
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: AppDimensions.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppDimensions.radiusLg),
                            ),
                            image: relatedProduct.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      relatedProduct.imageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: relatedProduct.imageUrl == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              relatedProduct.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${relatedProduct.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color, {required bool isSelected}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 3,
        ),
      ),
    );
  }
}
