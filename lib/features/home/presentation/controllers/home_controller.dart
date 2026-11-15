import 'package:get/get.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/usecases/get_products.dart';

class HomeController extends GetxController {
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetProductsUseCase? _getProductsUseCase;

  HomeController({
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    GetProductsUseCase? getProductsUseCase,
  })  : _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getProductsUseCase = getProductsUseCase;

  final Rxn<User> currentUser = Rxn<User>(UserSession.instance.currentUser);
  final RxBool isLoading = false.obs;
  final RxList<Product> popularProducts = <Product>[].obs;
  final RxBool isLoadingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (UserSession.instance.currentUser != null) {
      currentUser.value = UserSession.instance.currentUser;
    }
    loadCurrentUser();
    loadPopularProducts();
  }

  Future<void> reload() async {
    await Future.wait([
      loadCurrentUser(),
      loadPopularProducts(),
      if (Get.isRegistered<CategoriesController>())
        Get.find<CategoriesController>().fetchCategories(),
    ]);
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      final fetched = await _getCurrentUserUseCase();
      if (fetched != null) {
        currentUser.value = fetched;
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPopularProducts() async {
    if (_getProductsUseCase == null) return;
    isLoadingProducts.value = true;
    try {
      final list = await _getProductsUseCase(limit: 12);
      popularProducts.assignAll(list);
    } catch (_) {
      popularProducts.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> logout() async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );
    if (!confirmed) return;
    try {
      await _logoutUseCase();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Helpers.showError('Failed to logout');
    }
  }
}
