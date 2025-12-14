import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class SaleService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllSales() async {
    final res = await _dio.get('/sales/');
    return res.data;
  }
}
