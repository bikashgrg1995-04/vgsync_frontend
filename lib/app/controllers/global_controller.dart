import 'package:get/get.dart';

enum DashboardRefreshType {
  all,
  stock,
  purchase,
  sale,
  staff,
  order,
  followup,
  charts,
}

class GlobalController extends GetxController {
  /// Dashboard refresh event bus
  /// Holds all sections that need refresh
  var refreshTriggers = <DashboardRefreshType>[].obs;

  /// Trigger dashboard refresh for a specific type
  void triggerRefresh(DashboardRefreshType type) {
    if (!refreshTriggers.contains(type)) {
      refreshTriggers.add(type);
    }
  }

  /// Remove a trigger after it is handled
  void removeTrigger(DashboardRefreshType type) {
    refreshTriggers.remove(type);
  }

  // ---------------- Other globals ----------------

  var selectedMenu = 'Dashboard'.obs;

  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }

  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  RxBool isOnline = true.obs;

  void setOnline(bool status) {
    isOnline.value = status;
  }

  RxBool isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
