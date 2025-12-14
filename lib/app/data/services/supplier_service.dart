import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class SupplierService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllSuppliers() async {
    final res = await _dio.get('/suppliers/');
    return res.data;
  }
}
