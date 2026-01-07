import 'package:dio/dio.dart';
import '../models/followup_model.dart';
import 'api_service.dart';

class FollowUpService {
  final Dio _dio = ApiService.dio;

  // ================= FETCH =================
  Future<List<FollowUpModel>> fetchFollowUps() async {
    try {
      final response = await _dio.get('/followups/');

      if (response.statusCode == 200) {
        final data = response.data;

        final List results = data['results'] ?? [];

        return results
            .map(
              (e) => FollowUpModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load follow-ups');
      }
    } catch (e) {
      throw Exception('Fetch follow-ups failed: $e');
    }
  }

  // ================= TERMINATE =================
  Future<void> terminateFollowUp(int id) async {
    try {
      final response = await _dio.post('/followups/$id/terminate/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to terminate follow-up');
      }
    } catch (e) {
      throw Exception('Terminate request failed: $e');
    }
  }
}
