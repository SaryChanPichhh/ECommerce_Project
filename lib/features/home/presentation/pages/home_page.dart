import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/bindings/cart_binding.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../categories/presentation/widgets/category_list.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_grid_card.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.reload,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme),
                const SizedBox(height: AppDimensions.md),
                _buildSearchPill(context, theme),
                const SizedBox(height: AppDimensions.lg),
                const _AutoSlideshow(),
                const SizedBox(height: AppDimensions.lg),
                const CategoryList(),
                const SizedBox(height: AppDimensions.lg),
                _buildProductsList(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Obx(() {
          final user = controller.currentUser.value;
          final avatarUrl = user?.avatar;
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? AppNetworkImage(
                      imageUrl: avatarUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorWidget: Image.asset(
                        'assets/images/profile.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/profile.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          );
        }),
        const SizedBox(width: AppDimensions.sm + 4),
        Expanded(
          child: Obx(() {
            final user = controller.currentUser.value;
            final displayName = (user?.name != null && user!.name.trim().isNotEmpty)
                ? user.name
                : 'guest'.tr;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_greeting'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(width: AppDimensions.xs),
        _buildCartActionButton(theme, isDark),
        const SizedBox(width: AppDimensions.xs),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.6),
            ),
          ),
          child: IconButton(
            tooltip: 'notification'.tr,
            onPressed: () => Get.toNamed(AppRoutes.profileNotification),
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCartActionButton(ThemeData theme, bool isDark) {
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.6),
        ),
      ),
      child: Obx(() {
        final count = cartController.cart.value?.items.length ?? 0;
        return IconButton(
          tooltip: 'my_cart'.tr,
          onPressed: () => Get.toNamed(AppRoutes.cart),
          icon: Badge(
            backgroundColor: AppColors.error,
            textColor: Colors.white,
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag_outlined, size: 21),
          ),
          color: theme.colorScheme.onSurface,
        );
      }),
    );
  }

  Widget _buildSearchPill(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.products),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppDimensions.sm + 2),
              Expanded(
                child: Text(
                  'search_products_hint'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'popular_products'.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.products),
              child: Text('see_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Obx(() {
          if (controller.isLoadingProducts.value &&
              controller.popularProducts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
              child: AppLoading(message: 'loading_products'.tr),
            );
          }
          if (controller.popularProducts.isEmpty) {
            return AppEmpty(
              message: 'no_products_found'.tr,
              actionLabel: 'explore_catalog'.tr,
              onAction: () => Get.toNamed(AppRoutes.products),
            );
          }
          return GridView.builder(
            itemCount: controller.popularProducts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppDimensions.md,
              crossAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              final product = controller.popularProducts[index];
              return ProductGridCard(
                product: product,
                onTap: () => Get.toNamed(
                  '/products/${product.id}',
                  arguments: product.id,
                ),
                onAddToCartTap: () => _handleAddToCart(product),
              );
            },
          );
        }),
      ],
    );
  }

  Future<void> _handleAddToCart(Product product) async {
    if (!Get.isRegistered<CartController>()) {
      CartBinding().dependencies();
    }
    final cartController = Get.find<CartController>();
    final inStockVariants = product.variants.where((v) => v.isInStock);
    final selectedVariant = inStockVariants.isNotEmpty
        ? inStockVariants.first
        : (product.variants.isNotEmpty ? product.variants.first : null);
    await cartController.addToCart(
      productId: product.id,
      variantId: selectedVariant?.id,
      quantity: 1,
      productName: product.name,
      unitPrice: selectedVariant?.price ?? product.price,
      productImageUrl: product.imageUrl,
      variantName: selectedVariant?.name,
    );
  }
}

class _HeroSlideData {
  final String badgeKey;
  final String titleKey;
  final String subtitle;
  final String ctaKey;
  final String r2Key;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _HeroSlideData({
    required this.badgeKey,
    required this.titleKey,
    required this.subtitle,
    required this.ctaKey,
    required this.r2Key,
    required this.gradient,
    required this.onTap,
  });
}

class _AutoSlideshow extends StatefulWidget {
  const _AutoSlideshow();

  @override
  State<_AutoSlideshow> createState() => _AutoSlideshowState();
}

class _AutoSlideshowState extends State<_AutoSlideshow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  late final List<_HeroSlideData> _slides = [
    _HeroSlideData(
      badgeKey: 'flash_deals',
      titleKey: 'tech_essentials',
      subtitle: 'MacBook Pro M4 & UltraPhone 15',
      ctaKey: 'shop_now',
      r2Key: 'stores/tech-banner.jpg',
      gradient: const [Color(0xFF1E3A8A), Color(0xFF2563EB)],
      onTap: () => Get.toNamed(AppRoutes.products),
    ),
    _HeroSlideData(
      badgeKey: 'new_arrivals',
      titleKey: 'streetwear_drop',
      subtitle: 'Heritage Hoodies & Apex Nitro',
      ctaKey: 'explore',
      r2Key: 'stores/fashion-banner.jpg',
      gradient: const [Color(0xFF5B21B6), Color(0xFF7C3AED)],
      onTap: () => Get.toNamed(AppRoutes.products),
    ),
    _HeroSlideData(
      badgeKey: 'featured_deals',
      titleKey: 'new_arrivals',
      subtitle: 'MacBook Pro 14 M4 Pro',
      ctaKey: 'shop_now',
      r2Key: 'products/macbook-pro-14-m4.jpg',
      gradient: const [Color(0xFF0F766E), Color(0xFF06B6D4)],
      onTap: () => Get.toNamed(
        '/products/prod-000010',
        arguments: 'prod-000010',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_currentPage + 1) % _slides.length;
      if (mounted) {
        setState(() {
          _currentPage = next;
        });
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 176,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => _buildSlide(context, _slides[index]),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 22 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSlide(BuildContext context, _HeroSlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: slide.onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background R2 image
              AppNetworkImage(
                imageUrl: slide.r2Key,
                fit: BoxFit.cover,
                backgroundColor: slide.gradient.first,
                errorWidget: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: slide.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Modern dark scrim for crisp text legibility
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.32),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        slide.badgeKey.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.titleKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slide.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusRound,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.ctaKey.tr,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
