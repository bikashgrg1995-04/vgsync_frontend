import 'package:dio/dio.dart';
import 'api_service.dart';

class CustomerService {
  final Dio _dio = ApiService.dio;

  Future<List> getAllCustomers() async {
    final res = await _dio.get('/customers/');
    return res.data['results']; // assuming paginated response
  }

  Future<Map<String, dynamic>> addCustomer(Map<String, dynamic> data) async {
    final res = await _dio.post('/customers/', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> updateCustomer(
      int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/customers/$id/', data: data);
    return res.data;
  }

  Future<void> deleteCustomer(int id) async {
    await _dio.delete('/customers/$id/');
  }
}
