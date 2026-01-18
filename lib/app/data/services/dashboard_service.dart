import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class DashboardService {
  final ApiService apiService = Get.find();

  /// Fetch dashboard data for a given period
  /// [period] can be 'daily', 'weekly', 'monthly', '3month', '6month', 'yearly'
  Future<Map<String, dynamic>> fetchDashboard(
      {String period = 'monthly'}) async {
    final Dio dio = ApiService.dio;

    try {
      final response = await dio.get(
        '/dashboard/',
        queryParameters: {'period': period}, // Add period as query param
      );
      return response.data; // RAW JSON
    } catch (e) {
      // AppSnackbar.error("Dashboard fetch error: $e");
      rethrow;
    }
  }
}
