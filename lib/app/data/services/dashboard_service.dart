import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class DashboardService {
  final ApiService apiService = Get.find();

  Future<Map<String, dynamic>> fetchDashboard() async {
    final Dio _dio = ApiService.dio;
    final response = await _dio.get('/dashboard/');
    return response.data; // RAW JSON
  }
}
