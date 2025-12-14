import '../models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService userService;

  UserRepository({required this.userService});

  Future<UserModel> getProfile() {
    return userService.getProfile();
  }
}
