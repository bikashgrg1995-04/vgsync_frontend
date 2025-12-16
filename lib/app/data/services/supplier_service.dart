import 'package:vgsync_frontend/app/data/services/api_service.dart';

class SupplierService {
  final _dio = ApiService.dio;

  Future<List<dynamic>> getAllSuppliers() async {
    final response = await _dio.get('/suppliers/');
    return response.data['results'] ?? [];
  }

  Future<Map<String, dynamic>> addSupplier(Map<String, dynamic> data) async {
    final response = await _dio.post('/suppliers/', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateSupplier(
      int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/suppliers/$id/', data: data);
    return response.data;
  }

  Future<void> deleteSupplier(int id) async {
    await _dio.delete('/suppliers/$id/');
  }
}
