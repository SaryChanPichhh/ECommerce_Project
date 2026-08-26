import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/bindings/product_binding.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_form_page.dart';
import '../../features/customers/presentation/bindings/customer_binding.dart';
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/orders/presentation/bindings/order_binding.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/bindings/profile_binding.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../bindings/main_nav_binding.dart';
import '../pages/main_nav_page.dart';
import 'app_routes.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/payment_page.dart';
import '../../features/cart/presentation/pages/edit_address_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/language_page.dart';
import '../../features/profile/presentation/pages/legal_policies_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';


/// Application pages configuration.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentPage(),
    ),
    GetPage(
      name: AppRoutes.editAddress,
      page: () => const EditAddressPage(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productCreate,
      page: () => const ProductFormPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productEdit,
      page: () => const ProductFormPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerListPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerCreate,
      page: () => const CustomerFormPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerEdit,
      page: () => const CustomerFormPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerDetail,
      page: () => const CustomerDetailPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
      // Profile sub-pages
      GetPage(
        name: AppRoutes.profileEdit,
        page: () => const EditProfilePage(),
        binding: ProfileBinding(),
      ),
      GetPage(
        name: AppRoutes.profileChangePassword,
        page: () => const ChangePasswordPage(),
      ),
      GetPage(
        name: AppRoutes.profileNotification,
        page: () => const NotificationPage(),
      ),
      GetPage(
        name: AppRoutes.profileLanguage,
        page: () => const LanguagePage(),
      ),
      GetPage(
        name: AppRoutes.profileLegalPolicies,
        page: () => const LegalPoliciesPage(),
      ),
      GetPage(
        name: AppRoutes.profileHelpSupport,
        page: () => const HelpSupportPage(),
      ),
    ];
}