import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/user_model.dart';
import 'package:vgsync_frontend/app/data/repositories/auth_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/user_repository.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthController({
    required this.authRepository,
    required this.userRepository,
  });

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;

  RxBool isPasswordHidden = true.obs;

  /// ================= LOGIN =================
  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      DesktopToast.show(
        "Invalid username or password",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      // ✅ Call login and check success
      final success = await authRepository.login(username, password);

      if (!success) {
        DesktopToast.show(
          "Invalid username or password",
          backgroundColor: Colors.redAccent,
        );
        return;
      }

      // ✅ Fetch user profile
      final profile = await userRepository.getProfile();
      user.value = profile;
      isLoggedIn.value = true;

      // ✅ Clear login form
      usernameController.clear();
      passwordController.clear();

      Get.offAllNamed(AppRoutes.navigation);
      DesktopToast.show(
        "Login Successful",
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        "Something went wrong",
        backgroundColor: Colors.redAccent,
      );
      print("Login error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {
      // ignore errors on logout
    }

    user.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed(AppRoutes.login);
    DesktopToast.show(
      "Logout Successful",
      backgroundColor: Colors.greenAccent,
    );
  }
}