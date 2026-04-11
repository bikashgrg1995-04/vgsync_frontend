import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final Dio _dio = ApiService.dio;

 Future<UserModel> getProfile() async {
  final response = await _dio.get("/users/");

  if (response.statusCode != 200 || response.data is! List) {
    throw Exception("Failed to load profile");
  }

  final usersList = List<Map<String, dynamic>>.from(response.data);
  if (usersList.isEmpty) {
    throw Exception("No user found");
  }

  return UserModel.fromJson(usersList.first);
}
}
