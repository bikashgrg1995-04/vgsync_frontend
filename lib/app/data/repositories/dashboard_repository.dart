import 'package:vgsync_frontend/app/data/models/dashboard_model.dart';
import 'package:vgsync_frontend/app/data/services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService dashboardService;

  DashboardRepository({required this.dashboardService});

  Future<DashboardSummary> getDashboardData() {
    return dashboardService.fetchDashboard();
  }
}
