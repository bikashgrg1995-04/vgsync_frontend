// app/data/services/dashboard_service.dart

import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class DashboardService {
  final Dio _dio = ApiService.dio;

  // =======================================================
  // 📊 CHARTS ONLY
  // =======================================================
  Future<Map<String, dynamic>> fetchCharts({
    String period = 'monthly',
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/charts/',
        queryParameters: {
          'period': period,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Charts error: ${e.response?.data}');
      rethrow;
    }
  }

  // =======================================================
  // 💳 CREDIT ONLY (SALE + PURCHASE) — PAGINATED
  // =======================================================
  Future<Map<String, dynamic>> fetchCredit({
    String period = 'monthly',
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/credit/',
        queryParameters: {
          'period': period,
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Credit error: ${e.response?.data}');
      rethrow;
    }
  }

  // // =======================================================
  // // 💳 EMI CREDIT — PAGINATED
  // // =======================================================
  // Future<Map<String, dynamic>> fetchEMICredit({
  //   int page = 1,
  //   int pageSize = 5,
  // }) async {
  //   try {
  //     final response = await _dio.get(
  //       '/dashboard/credit/emi/', // <-- new EMI endpoint
  //       queryParameters: {
  //         'page': page,
  //         'page_size': pageSize,
  //       },
  //     );
  //     return response.data as Map<String, dynamic>;
  //   } on DioException catch (e) {
  //     print('EMI Credit error: ${e.response?.data}');
  //     rethrow;
  //   }
  // }

  // =======================================================
  // 📞 FOLLOWUPS TABLE — PAGINATED
  // =======================================================
  Future<Map<String, dynamic>> fetchFollowups({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/tables/followups/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Followups error: ${e.response?.data}');
      rethrow;
    }
  }

  // =======================================================
  // 📦 LOW STOCK TABLE — PAGINATED
  // =======================================================
  Future<Map<String, dynamic>> fetchLowStock({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/tables/low-stock/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Low stock error: ${e.response?.data}');
      rethrow;
    }
  }

  // =======================================================
  // 🧾 ORDERS TABLE — PAGINATED
  // =======================================================
  Future<Map<String, dynamic>> fetchOrders({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/tables/orders/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Orders error: ${e.response?.data}');
      rethrow;
    }
  }

  // =======================================================
  // 👨‍🔧 STAFF SALARY TABLE — PAGINATED
  // =======================================================
  Future<Map<String, dynamic>> fetchStaffSalaries({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard/tables/staff-salaries/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Staff salary error: ${e.response?.data}');
      rethrow;
    }
  }
}
