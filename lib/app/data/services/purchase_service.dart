import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class PurchaseService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllPurchases() async {
    final res = await _dio.get('/purchases/');
    return res.data;
  }
}
