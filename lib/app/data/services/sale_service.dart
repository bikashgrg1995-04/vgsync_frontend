import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/sale_model.dart';

class SaleService {
  final Dio _dio = ApiService.dio;

  // ================= FETCH =================
  Future<List<SaleModel>> fetchSales() async {
    final res = await _dio.get('/sales/');
    final list = res.data['results'] ?? res.data;

    return (list as List).map((saleJson) {
      return _parseSaleJson(saleJson);
    }).toList();
  }

  // ================= CREATE =================
  Future<SaleModel> createSale(SaleModel sale) async {
    final payload = sale.toBackendJson();
    final res = await _dio.post('/sales/', data: payload);

    return _parseSaleJson(res.data);
  }

  // ================= UPDATE =================
  Future<SaleModel> updateSale(SaleModel sale) async {
    final payload = sale.toBackendJson();
    final res = await _dio.put('/sales/${sale.id}/', data: payload);

    return _parseSaleJson(res.data);
  }

  // ================= DELETE =================
  Future<void> deleteSale(int id) async {
    await _dio.delete('/sales/$id/');
  }

  // ================= HELPER =================
  SaleModel _parseSaleJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((item) {
          if (item is Map<String, dynamic>) {
            return SaleItemModel.fromJson(item); // just use item directly
          }
          return null;
        })
        .whereType<SaleItemModel>()
        .toList();

    json['items'] = itemsList;
    return SaleModel.fromJson(json);
  }
}
