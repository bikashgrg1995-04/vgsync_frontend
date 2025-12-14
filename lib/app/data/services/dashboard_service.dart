import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  Future<DashboardSummary> fetchDashboard() async {
    final response = await ApiService.dio.get('/dashboard/');
    return DashboardSummary.fromJson(response.data['summary']);
  }
}
