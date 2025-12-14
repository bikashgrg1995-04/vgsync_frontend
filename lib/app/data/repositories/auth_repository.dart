import 'package:vgsync_frontend/utils/storage.dart';

import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository({required this.authService});

  Future<void> login(String username, String password) async {
    final data = await authService.login(username, password);

    await Storage.write('access_token', data['access']);
    await Storage.write('refresh_token', data['refresh']);
  }

  Future<void> logout() async {
    await Storage.clear();
  }
}
