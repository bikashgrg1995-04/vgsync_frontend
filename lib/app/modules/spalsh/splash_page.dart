import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/data/repositories/auth_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/user_repository.dart';
import 'package:vgsync_frontend/app/data/services/auth_service.dart';
import 'package:vgsync_frontend/app/data/services/user_service.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/utils/constants.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'package:vgsync_frontend/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    // ✅ Use existing AuthController from bindings if available
    authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(
            AuthController(
              authRepository: AuthRepository(authService: AuthService()),
              userRepository: UserRepository(userService: UserService()),
            ),
          );

    // 🔹 Wait for 4 seconds before proceeding
    await Future.delayed(const Duration(seconds: 4));

    await _handleAutoLogin();
  }

  Future<void> _handleAutoLogin() async {
    final accessToken = await Storage.read('access_token');
    final refreshToken = await Storage.read('refresh_token');

    // ----------------- CASE 1: access token exists -----------------
    if (accessToken != null) {
      try {
        final profile = await authController.userRepository.getProfile();
        authController.user.value = profile;
        authController.isLoggedIn.value = true;

        Get.offAllNamed(AppRoutes.navigation);
        return;
      } catch (_) {
        // Token invalid or expired
      }
    }

    // ----------------- CASE 2: refresh token exists -----------------
    if (refreshToken != null) {
      try {
        final success = await AuthService().refreshToken(refreshToken);

        if (success) {
          // 🔹 Profile fetch after token refresh
          final profile = await authController.userRepository.getProfile();
          authController.user.value = profile;
          authController.isLoggedIn.value = true;

          Get.offAllNamed(AppRoutes.navigation);
          return;
        }
      } catch (e) {
        print('Auto login refresh failed: $e');
      }
    }

    // ----------------- CASE 3: No valid token -----------------
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppConstants.logo,
              width: SizeConfig.sw(0.3),
              height: SizeConfig.sw(0.3),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}