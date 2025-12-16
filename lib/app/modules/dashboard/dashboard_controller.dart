import 'package:get/get.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;

  DashboardController({required this.dashboardRepository});

  RxBool isLoading = false.obs;

  // -------------------------
  // Reactive data
  // -------------------------
  var summary = DashboardSummary.empty().obs;
  var lowStockItems = <LowStockItem>[].obs;
  var upcomingFollowups = <DashboardFollowupItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // -------------------------
  // Load dashboard data
  // -------------------------
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      final data = await dashboardRepository.getDashboard();

      // Update reactive fields
      summary.value = data.summary;
      lowStockItems.value = data.lowStockItems;
      upcomingFollowups.value = data.upcomingFollowups;
    } catch (e) {
      print('Dashboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
