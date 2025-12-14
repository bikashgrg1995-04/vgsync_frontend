import 'package:dio/dio.dart';
import 'api_service.dart';

class FollowUpService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllFollowUps() async {
    final res = await _dio.get('/followups/');
    return res.data['results']; // <--- use results array
  }

  Future<Map<String, dynamic>> updateFollowUp(
      int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/followups/$id/', data: data);
    return res.data['results']; // <--- use results object
  }

  Future<void> deleteFollowUp(int id) async {
    await _dio.delete('/followups/$id/');
  }
}
