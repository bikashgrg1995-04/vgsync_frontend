import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class DashboardService {
  final ApiService apiService = Get.find();

  Future<Map<String, dynamic>> fetchDashboard() async {
    final Dio dio = ApiService.dio;
    final response = await dio.get('/dashboard/');
    print('DashboardService response: ${response.data}');
    return response.data; // RAW JSON
  }
}
