import 'package:get/get.dart';

class GlobalController extends GetxController {
  /// increases whenever any data changes
  final RxInt refreshTick = 0.obs;
  void triggerRefresh() {
    refreshTick.value++;
  }

  // ----------------------------
  // Theme
  // ----------------------------
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  // ----------------------------
  // App-wide offline/online status
  // ----------------------------
  RxBool isOnline = true.obs;

  void setOnline(bool status) {
    isOnline.value = status;
  }

  // ----------------------------
  // App-wide loading state
  // ----------------------------
  RxBool isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }

  // ----------------------------
  // You can add more global state here
  // ----------------------------
}
