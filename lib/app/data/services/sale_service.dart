import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class SaleService {
  final Dio _dio = ApiService.dio;

  Future<List<SaleModel>> fetchSales() async {
    final res = await _dio.get('/sales/');
    final List data = res.data['results'];
    return data.map((e) => SaleModel.fromJson(e)).toList();
  }

  Future<SaleModel> createSale(SaleModel sale) async {
    final res = await _dio.post('/sales/', data: sale.toJson());
    return SaleModel.fromJson(res.data);
  }

  Future<SaleModel> updateSale(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/sales/$id/', data: data);
    return SaleModel.fromJson(res.data);
  }

  Future<void> deleteSale(int id) async {
    await _dio.delete('/sales/$id/');
  }
}
