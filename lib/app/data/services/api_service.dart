import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/utils/storage.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/v1",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        // ---------------- REQUEST ----------------
        onRequest: (options, handler) async {
          final accessToken = await Storage.read('access_token');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },

        // ---------------- ERROR ----------------
        onError: (DioException err, handler) async {
          if (err.response?.statusCode == 401) {
            final refreshToken = await Storage.read('refresh_token');

            if (refreshToken == null) {
              await _logout();
              return handler.next(err);
            }

            try {
              // 🔄 REFRESH TOKEN
              final refreshDio = Dio();
              final refreshResponse = await refreshDio.post(
                'http://127.0.0.1:8000/api/v1/login/refresh/',
                data: {'refresh': refreshToken},
              );

              final newAccess = refreshResponse.data['access'];
              final newRefresh = refreshResponse.data['refresh'];

              await Storage.write('access_token', newAccess);
              await Storage.write('refresh_token', newRefresh);

              // 🔁 RETRY ORIGINAL REQUEST
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccess';

              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);
            } catch (e) {
              await _logout();
            }
          }

          handler.next(err);
        },
      ),
    );

  // ---------------- LOGOUT ----------------
  static Future<void> _logout() async {
    await Storage.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
