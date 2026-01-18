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

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      DesktopToast.show("Invalid username or password",  backgroundColor: Colors.redAccent,);
      return;
    }

    try {
      isLoading.value = true;

      await authRepository.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      final profile = await userRepository.getProfile();

      user.value = profile;
      isLoggedIn.value = true;

      // ✅ Clear username & password after successful login
      usernameController.clear();
      passwordController.clear();

      Get.offAllNamed(AppRoutes.navigation);
      DesktopToast.show("Login Successful",  backgroundColor: Colors.greenAccent,);
    } catch (e) {
      DesktopToast.show("Invalid username or password",  backgroundColor: Colors.redAccent,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    user.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed(AppRoutes.login);
    DesktopToast.show("Logout Successful",  backgroundColor: Colors.greenAccent,);
  }
}
