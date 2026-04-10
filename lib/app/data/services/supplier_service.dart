import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final Dio _dio = ApiService.dio;

  Future<List<SupplierModel>> getAllSuppliers() async {
    final res = await _dio.get('/suppliers/');
    final data = res.data;
    final List list = data is Map ? (data['results'] ?? []) : data;
    return list.map((e) => SupplierModel.fromJson(e)).toList();
  }

  Future<SupplierModel> addSupplier(Map<String, dynamic> data) async {
    final res = await _dio.post('/suppliers/', data: data);
    return SupplierModel.fromJson(res.data);
  }

  Future<SupplierModel> updateSupplier(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/suppliers/$id/', data: data);
    return SupplierModel.fromJson(res.data);
  }

  Future<void> deleteSupplier(int id) async {
    await _dio.delete('/suppliers/$id/');
  }
}