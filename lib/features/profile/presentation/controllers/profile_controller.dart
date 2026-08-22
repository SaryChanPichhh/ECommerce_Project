import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';

class ProfileController extends GetxController {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileController({required GetCurrentUserUseCase getCurrentUserUseCase, required LogoutUseCase logoutUseCase})
      : _getCurrentUserUseCase = getCurrentUserUseCase, _logoutUseCase = logoutUseCase;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() { super.onInit(); loadProfile(); }

  Future<void> loadProfile() async {
    isLoading.value = true; errorMessage.value = '';
    try { user.value = await _getCurrentUserUseCase(); }
    on Failure catch (e) { errorMessage.value = e.message; }
    catch (e) { errorMessage.value = 'Failed to load profile'; }
    finally { isLoading.value = false; }
  }

  Future<void> logout() async {
    final confirmed = await Helpers.showConfirmDialog(title: 'Logout', message: 'Are you sure you want to logout?');
    if (!confirmed) return;
    try { await _logoutUseCase(); Get.offAllNamed('/login'); }
    catch (e) { Helpers.showError('Failed to logout'); }
  }
}
