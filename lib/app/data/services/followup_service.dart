import 'package:dio/dio.dart';
import '../models/followup_model.dart';
import 'api_service.dart';

class FollowUpService {
  final Dio _dio = ApiService.dio;

  // ================= FETCH =================
  Future<List<FollowUpModel>> fetchFollowUps({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/followups/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // 🔥 API returns MAP not LIST
        final List results = data['results'] ?? [];

        return results
            .map(
              (e) => FollowUpModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      }

      throw Exception('Unexpected response code: ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Fetch follow-ups failed: $msg');
    } catch (e) {
      throw Exception('Fetch follow-ups failed: $e');
    }
  }

  // ================= TERMINATE =================
  Future<void> terminateFollowUp(
    int id, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/followups/$id/terminate/',
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          'Terminate failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Terminate request failed: $msg');
    } catch (e) {
      throw Exception('Terminate request failed: $e');
    }
  }
}
