import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class ItemService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllItems() async {
    final res = await _dio.get('/items/');
    return res.data;
  }
}
