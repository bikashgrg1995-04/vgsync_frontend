import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:vgsync_frontend/utils/storage.dart';

class AuthService {
  final Dio _dio = ApiService.dio;

  // ================= LOGIN =================
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        "/login/",
        data: {
          "username": username,
          "password": password,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.data}');

      if (response.statusCode != 200) return false;

      // Safely cast Map<dynamic,dynamic> → Map<String,dynamic>
      final data = Map<String, dynamic>.from(response.data as Map);

      final access = data['access']?.toString();
      final refresh = data['refresh']?.toString();

      if (access != null && refresh != null) {
        await Storage.write('access_token', access);
        await Storage.write('refresh_token', refresh);

         // Force Dio to use new token immediately
      ApiService.dio.options.headers['Authorization'] = 'Bearer $access';

        return true;
      }

      return false;
    } catch (e, st) {
      print('AuthService login error: $e');
      print(st);
      return false;
    }
  }

  // ================= REFRESH TOKEN =================
  Future<bool> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/login/refresh/',
        data: {'refresh': refreshToken},
      );

      final data = Map<String, dynamic>.from(response.data);
      final newAccess = data['access'] as String?;
      final newRefresh = data['refresh'] as String?;

      if (newAccess != null && newRefresh != null) {
        await Storage.write('access_token', newAccess);
        await Storage.write('refresh_token', newRefresh);
        return true;
      }

      return false;
    } catch (e) {
      print('AuthService refresh error: $e');
      return false;
    }
  }
}
