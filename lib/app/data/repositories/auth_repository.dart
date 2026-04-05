import 'package:vgsync_frontend/app/data/services/auth_service.dart';
import 'package:vgsync_frontend/utils/storage.dart';


class AuthRepository {
  final AuthService authService;

  AuthRepository({required this.authService});

  Future<bool> login(String username, String password) async {
    return await authService.login(username, password);
  }

  Future<bool> refreshToken(String refreshToken) async {
    return await authService.refreshToken(refreshToken);
  }

  Future<void> logout() async {
    // clear tokens
    await Storage.clear();
  }
}