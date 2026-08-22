import 'package:get/get.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/utils/helpers.dart';

class HomeController extends GetxController {
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  HomeController({
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      currentUser.value = await _getCurrentUserUseCase();
    } catch (_) {} finally {
      isLoading.value = false;
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
      Get.offAllNamed('/login');
    } catch (e) {
      Helpers.showError('Failed to logout');
    }
  }
}
