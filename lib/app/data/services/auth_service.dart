import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService.dio;

  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await _dio.post(
      "/login/",
      data: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode != 200 || response.data is! Map) {
      throw Exception("Login failed");
    }

    return Map<String, dynamic>.from(response.data);
  }
}
