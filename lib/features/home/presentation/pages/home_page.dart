import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Header
              _buildHeader(context),
              const SizedBox(height: AppDimensions.lg),

              // Row 2: Slideshow
              _buildSlideshow(),
              const SizedBox(height: AppDimensions.lg),

              // Row 3: Categories
              _buildCategories(context),
              const SizedBox(height: AppDimensions.lg),

              // Row 4: Products
              _buildProductsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Obx(() {
            final user = controller.currentUser.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  user?.name ?? 'Guest',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
        ),
        IconButton(
          onPressed: () {
            // Notification action
            Get.toNamed('/profile/notification');
          },
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSlideshow() {
    return const _AutoSlideshow();
  }


  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryItem(context, 'Electronics', Icons.devices),
              _buildCategoryItem(context, 'Clothing', Icons.checkroom),
              _buildCategoryItem(context, 'Shoes', Icons.do_not_step),
              _buildCategoryItem(context, 'Accessories', Icons.watch),
              _buildCategoryItem(context, 'Sports', Icons.sports_basketball),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon) {
    return InkWell(
      onTap: () {
        // Navigate to category product list
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Products',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/products'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.md,
          crossAxisSpacing: AppDimensions.md,
          childAspectRatio: 0.65,
          children: [
            _buildMockProductCard(
              context,
              name: 'Product 1',
              desc: 'High quality electronics',
              price: 29.99,
              rating: 4.5,
              orders: 120,
            ),
            _buildMockProductCard(
              context,
              name: 'Product 2',
              desc: 'Premium clothing item',
              price: 49.99,
              rating: 4.8,
              orders: 50,
            ),
            _buildMockProductCard(
              context,
              name: 'Product 3',
              desc: 'Comfortable running shoes',
              price: 19.99,
              rating: 4.2,
              orders: 300,
            ),
            _buildMockProductCard(
              context,
              name: 'Product 4',
              desc: 'Luxury watch accessory',
              price: 99.99,
              rating: 4.9,
              orders: 12,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMockProductCard(
    BuildContext context, {
    required String name,
    required String desc,
    required double price,
    required double rating,
    required int orders,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/products/1'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        // Handle favorite toggle
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|$orders+ sold',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
  }
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
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
    return SizedBox(
      height: 150,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _currentPage = index;
        },
        children: [
          _buildSlide('Banner 1', AppColors.primary),
          _buildSlide('Banner 2', AppColors.secondary),
          _buildSlide('Banner 3', AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildSlide(String title, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
