import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../favorite/presentation/bindings/favorite_binding.dart';
import '../../../favorite/presentation/controllers/favorite_controller.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_product_variants.dart';
import '../../domain/usecases/get_products.dart';
import '../bindings/product_binding.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _galleryController = PageController();
  int _currentImageIndex = 0;

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
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    if (!Get.isRegistered<FavoriteController>()) {
      FavoriteBinding().dependencies();
    }
    _loadProduct();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
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
        errorMessage = 'product_not_found'.tr;
        isLoading = false;
      });
      return;
    }

    String productId = rawId.trim();
    if (productId.contains('/')) {
      final segments = Uri.tryParse(productId)
          ?.pathSegments
          .where((s) => s.isNotEmpty)
          .toList();
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
          _currentImageIndex = 0;
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
      if (mounted) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = 'product_not_found'.tr;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVariants(String productId) async {
    if (!mounted) return;
    setState(() => isLoadingVariants = true);

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
        setState(() => isLoadingVariants = false);
      }
    }
  }

  Future<void> _loadRelatedProducts(String? category) async {
    if (!mounted) return;
    setState(() => isLoadingRelated = true);
    try {
      final getProducts = Get.find<GetProductsUseCase>();
      final result = await getProducts(limit: 12);
      if (mounted) {
        setState(() {
          relatedProducts = result
              .where(
                (p) =>
                    p.id != product?.id &&
                    (category == null ||
                        p.category == null ||
                        p.category == category),
              )
              .take(8)
              .toList();
          if (relatedProducts.isEmpty) {
            relatedProducts =
                result.where((p) => p.id != product?.id).take(8).toList();
          }
          isLoadingRelated = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoadingRelated = false);
      }
    }
  }

  List<String> get _galleryImages {
    if (product == null) return const [];
    if (product!.images.isNotEmpty) {
      final urls = List<String>.from(product!.images);
      if (product!.imageUrl != null &&
          product!.imageUrl!.isNotEmpty &&
          !urls.contains(product!.imageUrl)) {
        urls.insert(0, product!.imageUrl!);
      }
      return urls;
    }
    if (product!.imageUrl != null && product!.imageUrl!.isNotEmpty) {
      return [product!.imageUrl!];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavoriteController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('product_detail'.tr),
        actions: [
          if (product != null)
            Obx(() {
              final isFav = favController.isFavorite(
                product!.id,
                defaultIsFavorite: product!.isFavorite,
              );
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.error : null,
                ),
                onPressed: () => favController.toggleFavoriteProduct(product!),
              );
            }),
          Obx(() {
            final cartCount = cartController.cart.value?.items.length ?? 0;
            return IconButton(
              tooltip: 'cart'.tr,
              icon: Badge(
                backgroundColor: AppColors.error,
                textColor: Colors.white,
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              onPressed: () => Get.toNamed(AppRoutes.cart),
            );
          }),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: product != null ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final currentUnitPrice = selectedVariant?.price ?? product!.price;
    final availableStock = selectedVariant?.stockQuantity ?? product!.quantity;
    final isOutOfStock = availableStock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
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
                    'total_price'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                  Text(
                    '\$${(currentUnitPrice * orderAmount).toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.md),
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
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: Text(isOutOfStock ? 'out_of_stock'.tr : 'add_to_cart'.tr),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm + 4,
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
      return AppLoading(message: 'loading_product'.tr);
    }

    if (errorMessage.isNotEmpty) {
      return AppError(message: errorMessage, onRetry: _loadProduct);
    }

    if (product == null) {
      return AppError(message: 'product_not_found'.tr);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final gallery = _galleryImages;
    final hasDiscount = product!.compareAtPrice != null &&
        product!.compareAtPrice! > product!.price;
    final discountPercent = hasDiscount
        ? ((product!.compareAtPrice! - product!.price) /
                product!.compareAtPrice! *
                100)
            .round()
        : 0;
    final currentPrice = selectedVariant?.price ?? product!.price;
    final availableStock = selectedVariant?.stockQuantity ?? product!.quantity;
    final ratingAvg = product!.ratingAverage > 0 ? product!.ratingAverage : 4.8;
    final ratingCount = product!.ratingCount > 0 ? product!.ratingCount : 24;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swipeable Hero Image Gallery
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 290,
              color: theme.cardColor,
              child: Stack(
                children: [
                  if (gallery.isEmpty)
                    const AppNetworkImage(
                      imageUrl: null,
                      width: double.infinity,
                      height: 290,
                      fallbackIcon: Icons.image_not_supported_outlined,
                      fallbackIconSize: 64,
                    )
                  else
                    PageView.builder(
                      controller: _galleryController,
                      itemCount: gallery.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return AppNetworkImage(
                          imageUrl: gallery[index],
                          width: double.infinity,
                          height: 290,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.inventory_2_outlined,
                          fallbackIconSize: 64,
                        );
                      },
                    ),

                  if (hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusRound),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  if (gallery.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(gallery.length, (idx) {
                          final active = idx == _currentImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 6,
                            width: active ? 20 : 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Title, Rating, Price & Quantity Controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product!.category != null &&
                        product!.category!.isNotEmpty) ...[
                      Text(
                        product!.category!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      product!.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        Text(
                          ratingAvg.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '($ratingCount ${'reviews'.tr})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                        if (product!.soldCount > 0)
                          Text(
                            '• ${product!.soldCount}+ ${'sold'.tr}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          '\$${currentPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            '\$${product!.compareAtPrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: secondaryColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    if (selectedVariant?.sku != null &&
                        selectedVariant!.sku!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'SKU: ${selectedVariant!.sku}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
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
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXl),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: orderAmount > 1
                                  ? theme.colorScheme.primary
                                  : secondaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$orderAmount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: orderAmount < availableStock
                              ? () => setState(() => orderAmount++)
                              : null,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXl),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: orderAmount < availableStock
                                  ? theme.colorScheme.primary
                                  : secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${'available'.tr}: $availableStock',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: availableStock > 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (product!.tags.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: product!.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: AppDimensions.lg),

          // Variants Section
          _buildVariantsSection(),

          // Description Card
          if (product!.description != null &&
              product!.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color:
                      theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'description'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    product!.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],

          // Merchant / Supplier Card
          Text(
            'supplier'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color:
                    theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.45),
              ),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: (product!.storeLogoUrl != null &&
                          product!.storeLogoUrl!.isNotEmpty)
                      ? AppNetworkImage(
                          imageUrl: product!.storeLogoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.storefront_rounded,
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: AppColors.primary,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.storeName ?? 'official_store'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'verified_merchant'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.products),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(92, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                  child: Text('view_shop'.tr),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          'related_products'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 204,
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
                  width: 144,
                  margin: const EdgeInsets.only(right: AppDimensions.md),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: theme.dividerColor
                          .withValues(alpha: isDark ? 0.25 : 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.16 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppNetworkImage(
                          imageUrl: relatedProduct.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.inventory_2_outlined,
                          fallbackIconSize: 32,
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${relatedProduct.price.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    if (isLoadingVariants) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'variants'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'variants_and_options'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selectedVariant != null)
              Flexible(
                child: Text(
                  selectedVariant!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
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
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (isOutOfStock
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                          : theme.cardColor),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : theme.dividerColor.withValues(
                            alpha: isOutOfStock ? 0.2 : 0.55,
                          ),
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
                                ? secondaryColor
                                : (isSelected ? AppColors.primary : null),
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
                              color: secondaryColor,
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
                            ? secondaryColor
                            : (isSelected ? AppColors.primary : secondaryColor),
                      ),
                    ),
                    if (isOutOfStock) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${'sold_out'.tr})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
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
