import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_product_variants.dart';
import '../../domain/usecases/get_products.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../favorite/presentation/bindings/favorite_binding.dart';
import '../../../favorite/presentation/controllers/favorite_controller.dart';
import '../bindings/product_binding.dart';

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
  List<ProductVariant> variants = [];
  ProductVariant? selectedVariant;
  bool isLoadingVariants = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    String? paramId = Get.parameters['id'];
    if (paramId != null && paramId.startsWith(':')) {
      paramId = Uri.tryParse(Get.currentRoute)?.queryParameters['id'];
    }
    final rawId = (paramId != null && paramId.trim().isNotEmpty)
        ? paramId
        : Get.arguments?.toString();
    if (rawId == null || rawId.trim().isEmpty || rawId.trim().startsWith(':')) {
      setState(() {
        errorMessage = 'Product ID not provided';
        isLoading = false;
      });
      return;
    }

    // Sanitize productId in case full URL or trailing slash was passed
    String productId = rawId.trim();
    if (productId.contains('/')) {
      final segments =
          Uri.tryParse(productId)?.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments != null && segments.isNotEmpty) {
        productId = segments.last;
      } else {
        productId = productId.replaceAll(RegExp(r'^/+|/+$'), '');
      }
    }

    try {
      if (!Get.isRegistered<GetProductUseCase>()) {
        ProductBinding().dependencies();
      }
      final useCase = Get.find<GetProductUseCase>();
      final result = await useCase(productId);
      if (mounted) {
        setState(() {
          product = result;
          if (result.variants.isNotEmpty) {
            variants = List<ProductVariant>.from(result.variants);
            final inStock = variants.where((v) => v.isInStock);
            selectedVariant =
                inStock.isNotEmpty ? inStock.first : variants.first;
          }
          isLoading = false;
        });
      }
      if (result.variants.isEmpty) {
        _loadVariants(productId);
      }
      _loadRelatedProducts(result.category);
    } on Failure catch (e) {
      debugPrint('Failure loading product ($productId): ${e.message}');
      if (mounted) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Unexpected error loading product ($productId): $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load product';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVariants(String productId) async {
    if (!mounted) return;
    setState(() {
      isLoadingVariants = true;
    });

    try {
      if (!Get.isRegistered<GetProductVariantsUseCase>()) {
        ProductBinding().dependencies();
      }
      final getVariants = Get.find<GetProductVariantsUseCase>();
      final result = await getVariants(productId);
      if (mounted) {
        setState(() {
          variants = List<ProductVariant>.from(result);
          if (variants.isNotEmpty) {
            final inStock = variants.where((v) => v.isInStock);
            selectedVariant =
                inStock.isNotEmpty ? inStock.first : variants.first;
          }
          isLoadingVariants = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoadingVariants = false;
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
      appBar: AppBar(
        title: Text('product_detail'.tr),
        actions: [
          if (product != null)
            Obx(() {
              if (!Get.isRegistered<FavoriteController>()) {
                FavoriteBinding().dependencies();
              }
              final favController = Get.find<FavoriteController>();
              final isFav = favController.isFavorite(
                product!.id,
                defaultIsFavorite: product!.isFavorite,
              );
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : null,
                ),
                onPressed: () => favController.toggleFavoriteProduct(product!),
              );
            }),
          Obx(() {
            final cartCount = Get.isRegistered<CartController>()
                ? (Get.find<CartController>().cart.value?.items.length ?? 0)
                : 0;
            return IconButton(
              tooltip: 'Cart',
              icon: Badge(
                backgroundColor: AppColors.error,
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              onPressed: () => Get.toNamed('/cart'),
            );
          }),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: product != null ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottomNavColor = Theme.of(context).cardColor;
    final currentUnitPrice = selectedVariant?.price ?? product!.price;
    final availableStock = selectedVariant?.stockQuantity ?? product!.quantity;
    final isOutOfStock = availableStock <= 0;

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
                    '\$${(currentUnitPrice * orderAmount).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: isOutOfStock
                    ? null
                    : () async {
                        if (product != null) {
                          if (!Get.isRegistered<CartController>()) {
                            CartBinding().dependencies();
                          }
                          await Get.find<CartController>().addToCart(
                            productId: product!.id,
                            variantId: selectedVariant?.id,
                            quantity: orderAmount,
                            productName: product!.name,
                            unitPrice: currentUnitPrice,
                            productImageUrl: product!.imageUrl,
                            variantName: selectedVariant?.name,
                          );
                        }
                      },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(isOutOfStock ? 'Out of Stock' : 'add_to_cart'.tr),
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
          Builder(
            builder: (context) {
              final currentPrice = selectedVariant?.price ?? product!.price;
              final availableStock =
                  selectedVariant?.stockQuantity ?? product!.quantity;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Title, Rating, Price, SKU
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product!.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(120 reviews)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${currentPrice.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (selectedVariant?.sku != null &&
                            selectedVariant!.sku!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SKU: ${selectedVariant!.sku}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$orderAmount',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: orderAmount < availableStock
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
                                  color: orderAmount < availableStock
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
                        'Available: $availableStock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: availableStock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.lg),

          // Second Row: Variants Section
          _buildVariantsSection(),

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
                child: Text('view_shop'.tr),
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

  Widget _buildVariantsSection() {
    if (isLoadingVariants) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variants',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.sm),
          const SizedBox(
            height: 36,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      );
    }

    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Variants & Options',
              style: theme
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (selectedVariant != null)
              Text(
                selectedVariant!.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: variants.map((variant) {
            final isSelected = selectedVariant?.id == variant.id;
            final isOutOfStock =
                variant.stockQuantity <= 0 || variant.status != 'active';

            return InkWell(
              onTap: isOutOfStock
                  ? null
                  : () {
                      setState(() {
                        selectedVariant = variant;
                        if (orderAmount > variant.stockQuantity &&
                            variant.stockQuantity > 0) {
                          orderAmount = 1;
                        }
                      });
                    },
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isOutOfStock
                          ? Colors.grey.withValues(alpha: 0.05)
                          : theme.cardColor),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isOutOfStock
                            ? Colors.grey.shade300
                            : AppColors.borderLight),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isOutOfStock
                                ? Colors.grey
                                : (isSelected
                                    ? AppColors.primary
                                    : null),
                            fontSize: 13,
                          ),
                        ),
                        if (variant.options.isNotEmpty)
                          Text(
                            variant.options
                                .map((o) => '${o.name}: ${o.value}')
                                .join(' • '),
                            style: TextStyle(
                              fontSize: 11,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${variant.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOutOfStock
                            ? Colors.grey
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                    if (isOutOfStock) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '(Sold out)',
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.lg),
      ],
    );
  }
}
