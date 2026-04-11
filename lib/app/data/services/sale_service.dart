import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class SaleService {
  final Dio _dio = ApiService.dio;

  // ================= FETCH =================
  Future<List<SaleModel>> fetchSales() async {
    final res = await _dio.get('/sales/');

    // Check if res.data is List or Map
    final data = res.data;

    List<dynamic> list;

    if (data is List) {
      // Direct list
      list = data;
    } else if (data is Map && data.containsKey('results')) {
      list = data['results'];
    } else {
      throw Exception('Unexpected response format');
    }

    return list.map((json) => SaleModel.fromJson(json)).toList();
  }

  // ================= CREATE =================
  Future<SaleModel> createSale(SaleModel sale) async {
    final res = await _dio.post('/sales/', data: sale.toBackendJson());
    return SaleModel.fromJson(res.data);
  }

  // ================= UPDATE =================
  Future<SaleModel> updateSale(SaleModel sale) async {
    final res = await _dio.put(
      '/sales/${sale.id}/',
      data: sale.toBackendJson(),
    );
    return SaleModel.fromJson(res.data);
  }

  // ================= DELETE =================
  Future<void> deleteSale(int id) async {
    await _dio.delete('/sales/$id/');
  }
}
