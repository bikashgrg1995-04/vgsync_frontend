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
    // Setup AuthController (if not already in bindings)
    authController = Get.put(
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
        // Try fetching profile to validate token
        final profile = await authController.userRepository.getProfile();

        authController.user.value = profile;
        authController.isLoggedIn.value = true;

        Get.offAllNamed(AppRoutes.navigation);
        return;
      } catch (_) {
        // Token invalid or expired
      }
    }

    // ----------------- CASE 2: access invalid but refresh exists -----------------
    if (refreshToken != null) {
      try {
        final newTokens = await AuthService().refreshToken(refreshToken);

        // Save new tokens
        await Storage.write('access_token', newTokens['access']);
        await Storage.write('refresh_token', newTokens['refresh']);

        // Fetch profile after refreshing
        final profile = await authController.userRepository.getProfile();
        authController.user.value = profile;
        authController.isLoggedIn.value = true;

        Get.offAllNamed(AppRoutes.dashboard);
        return;
      } catch (_) {
        // Refresh token failed, fallthrough to login
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
