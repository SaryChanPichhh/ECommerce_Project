import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/user_session.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';

class ProfileController extends GetxController {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileController({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase;

  final Rxn<User> user = Rxn<User>(UserSession.instance.currentUser);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (UserSession.instance.currentUser != null) {
      user.value = UserSession.instance.currentUser;
    }
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = user.value == null;
    errorMessage.value = '';
    try {
      final fetched = await _getCurrentUserUseCase();
      if (fetched != null) {
        user.value = fetched;
      }
    } on Failure catch (e) {
      if (user.value == null) {
        errorMessage.value = e.message;
      }
    } catch (e) {
      if (user.value == null) {
        errorMessage.value = 'Failed to load profile';
      }
    } finally {
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
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Helpers.showError('Failed to logout');
    }
  }
}
