import 'package:get/get.dart';

/// Controller for the main navigation screen.
/// Manages the currently selected tab index.
class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
