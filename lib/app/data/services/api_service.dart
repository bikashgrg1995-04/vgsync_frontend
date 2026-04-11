import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/constants.dart';
import 'package:vgsync_frontend/utils/storage.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        // ================= REQUEST =================
        onRequest: (options, handler) async {
          final accessToken = await Storage.read('access_token');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },

        // ================= ERROR =================
        onError: (DioException err, handler) async {
          // 🌐 Server not reachable (VGSync not running)
          if (_isServerDown(err)) {
             DesktopToast.show( 'Server सँग connect हुन सकेन। VGSync service start गर्नुहोस्।',  backgroundColor: Colors.redAccent,);
         
            return handler.next(err);
          }

          // 📡 Internet issue
          if (_isInternetError(err)) {

             DesktopToast.show( 'Internet connection check गर्नुहोस्।',  backgroundColor: Colors.redAccent,);
           
            return handler.next(err);
          }

          // 🔐 Token expired
          if (err.response?.statusCode == 401) {
            final refreshToken = await Storage.read('refresh_token');

            // ❌ No refresh token → force logout
            if (refreshToken == null || refreshToken.isEmpty) {
              await _forceLogout();
              return handler.next(err);
            }

            try {
              final refreshResponse = await Dio().post(
                '${AppConstants.baseUrl}/login/refresh/',
                data: {'refresh': refreshToken},
              );

              final newAccess = refreshResponse.data['access'];
              final newRefresh = refreshResponse.data['refresh'];

              await Storage.write('access_token', newAccess);
              await Storage.write('refresh_token', newRefresh);

              // 🔁 Retry original request
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccess';

              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);
            } catch (_) {
              await _forceLogout();
              return handler.next(err);
            }
          }

          handler.next(err);
        },
      ),
    );

  // ================= SERVER DOWN =================
  static bool _isServerDown(DioException err) {
    return err.type == DioExceptionType.connectionError &&
        err.error is SocketException;
  }

  // ================= INTERNET ERROR =================
  static bool _isInternetError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }

  // ================= FORCE LOGOUT =================
  static Future<void> _forceLogout() async {
    await Storage.clear();
     DesktopToast.show('Session expire भयो। कृपया फेरि login गर्नुहोस्।',  backgroundColor: Colors.redAccent,);
   
    Get.offAllNamed(AppRoutes.login);
  }
}
