import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/data/repositories/auth_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/user_repository.dart';
import 'package:vgsync_frontend/app/data/services/auth_service.dart';
import 'package:vgsync_frontend/app/data/services/user_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService());
    Get.put(UserService());

    Get.put(AuthRepository(authService: Get.find()));
    Get.put(UserRepository(userService: Get.find()));

    Get.put(AuthController(
      authRepository: Get.find(),
      userRepository: Get.find(),
    ));
  }
}
