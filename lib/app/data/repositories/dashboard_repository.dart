import 'package:vgsync_frontend/app/data/models/dashboard/charts.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/credit.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/followup.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/low_stock.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/orders.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/staffs_salary.dart';
import 'package:vgsync_frontend/app/data/services/dashboard_service.dart';

/// Enum to select chart / credit period
enum ChartPeriod { daily, weekly, monthly, threeMonths, sixMonths, yearly }

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository({required DashboardService dashboardService})
      : _dashboardService = dashboardService;

  // =======================================================
  // 📞 FOLLOWUPS (Paginated)
  // =======================================================
  Future<FollowupPaginatedResponse> getFollowups({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dashboardService.fetchFollowups(
        page: page,
        pageSize: pageSize,
      );
      return FollowupPaginatedResponse.fromJson(response);
    } catch (e) {
      print('Error fetching followups: $e');
      rethrow;
    }
  }

  // =======================================================
  // 📦 LOW STOCK (Paginated)
  // =======================================================
  Future<StockPaginatedResponse> getLowStock({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dashboardService.fetchLowStock(
        page: page,
        pageSize: pageSize,
      );
      return StockPaginatedResponse.fromJson(response);
    } catch (e) {
      print('Error fetching low stock: $e');
      rethrow;
    }
  }

  // =======================================================
  // 🧾 ORDERS (Paginated)
  // =======================================================
  Future<OrderPaginatedResponse> getOrders({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dashboardService.fetchOrders(
        page: page,
        pageSize: pageSize,
      );
      return OrderPaginatedResponse.fromJson(response);
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  // =======================================================
  // 👨‍🔧 STAFF SALARY (Paginated)
  // =======================================================
  Future<StaffSalaryPaginatedResponse> getStaffSalaries({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dashboardService.fetchStaffSalaries(
        page: page,
        pageSize: pageSize,
      );
      return StaffSalaryPaginatedResponse.fromJson(response);
    } catch (e) {
      print('Error fetching staff salaries: $e');
      rethrow;
    }
  }

  // =======================================================
  // 📊 DASHBOARD CHARTS ONLY
  // =======================================================
  Future<DashboardCharts> getDashboardCharts({
    ChartPeriod period = ChartPeriod.monthly,
  }) async {
    try {
      final response = await _dashboardService.fetchCharts(
        period: _mapPeriod(period),
      );
      return DashboardCharts.fromJson(response);
    } catch (e) {
      print('Error fetching dashboard charts: $e');
      // Return empty charts if API fails
      return DashboardCharts.empty();
    }
  }


  // =======================================================
  // 💳 DASHBOARD CREDIT (Paginated)
  // =======================================================
  Future<DashboardCreditPaginated> getDashboardCredit({
    ChartPeriod period = ChartPeriod.daily,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dashboardService.fetchCredit(
        period: _mapPeriod(period),
        page: page,
        pageSize: pageSize,
      );
      return DashboardCreditPaginated.fromJson(response);
    } catch (e) {
      print('Error fetching dashboard credit: $e');
      rethrow;
    }
  }

  // // =======================================================
  // // 💳 DASHBOARD EMI CREDIT (Paginated)
  // // =======================================================
  // Future<DashboardCreditPaginated> getDashboardEMICredit({
  //   int page = 1,
  //   int pageSize = 5,
  // }) async {
  //   try {
  //     final response = await _dashboardService.fetchEMICredit(
  //       page: page,
  //       pageSize: pageSize,
  //     );
  //     return DashboardCreditPaginated.fromJson(response);
  //   } catch (e) {
  //     print('Error fetching EMI dashboard credit: $e');
  //     rethrow;
  //   }
  // }

   // =======================================================
  // HELPER: Map enum to backend string
  // =======================================================
  String _mapPeriod(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.daily:
        return 'daily';
      case ChartPeriod.weekly:
        return 'weekly';
      case ChartPeriod.monthly:
        return 'monthly';
      case ChartPeriod.threeMonths:
        return '3months'; // match backend key
      case ChartPeriod.sixMonths:
        return '6months'; // match backend key
      case ChartPeriod.yearly:
        return 'yearly';
    }
  }
}
