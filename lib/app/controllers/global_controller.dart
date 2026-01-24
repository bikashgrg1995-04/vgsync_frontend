// app/controllers/global_controller.dart
import 'package:get/get.dart';

/// Types of dashboard refresh events
enum DashboardRefreshType {
  all, // refresh everything
  stock, // low stock table
  charts,
  credit,
  staff, // staff salary table
  order, // orders table
  followup, // follow-up table
}

class GlobalController extends GetxController {
  // ---------------- Dashboard Refresh ----------------
  /// Holds all sections that need refresh
   RxList<DashboardRefreshType> refreshTriggers = <DashboardRefreshType>[].obs;

  /// Trigger dashboard refresh for a specific type
  void triggerRefresh(DashboardRefreshType type) {
    // Avoid duplicates
    if (!refreshTriggers.contains(type)) {
      refreshTriggers.add(type);
    }
  }

  /// Remove a trigger after it is handled
  void removeTrigger(DashboardRefreshType type) {
    refreshTriggers.remove(type);
  }

  /// Safe listener helper for controllers:
  /// Example usage in DashboardController:
  /// ever(globalController.refreshTriggers, (_) {
  ///   globalController.handleRefreshSafely(DashboardRefreshType.sale, () {
  ///     // Your sale refresh logic
  ///   });
  /// });
  void handleRefreshSafely(
      DashboardRefreshType type, void Function() callback) {
    // Work on a copy to avoid concurrent modification
    final triggersCopy = List<DashboardRefreshType>.from(refreshTriggers);
    for (var t in triggersCopy) {
      if (t == type) {
        callback();
        removeTrigger(t); // safely remove
      }
    }
  }

  // ---------------- Menu ----------------
  var selectedMenu = 'Dashboard'.obs;

  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }

  // ---------------- Theme ----------------
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  // ---------------- Online status ----------------
  RxBool isOnline = true.obs;

  void setOnline(bool status) {
    isOnline.value = status;
  }

  // ---------------- Loading ----------------
  RxBool isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
