import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../core/theme/app_colors.dart';
import '../../features/favorite/presentation/pages/favorite_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';

/// Main navigation screen with persistent bottom navigation bar.
/// Contains 5 tabs: Home, My Order, Favorite, Search, My Profile.
class MainNavPage extends StatelessWidget {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const HomePage(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: 'home'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.textSecondaryLight,
          ),
        ),
        PersistentTabConfig(
          screen: const OrderListPage(),
          item: ItemConfig(
            icon: const Icon(Icons.shopping_bag),
            title: 'order'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.textSecondaryLight,
          ),
        ),
        PersistentTabConfig(
          screen: const SearchPage(),
          item: ItemConfig(
            icon: const Icon(Icons.search),
            title: 'search'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.textSecondaryLight,
          ),
        ),
        PersistentTabConfig(
          screen: const FavoritePage(),
          item: ItemConfig(
            icon: const Icon(Icons.favorite),
            title: 'favorite'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.textSecondaryLight,
          ),
        ),

        PersistentTabConfig(
          screen: const ProfilePage(),
          item: ItemConfig(
            icon: const Icon(Icons.settings),
            title: 'setting'.tr,
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.textSecondaryLight,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}
