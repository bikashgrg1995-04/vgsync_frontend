import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/sale_model.dart';

class SaleService {
  final Dio _dio = ApiService.dio;

  // ---------------- FETCH ----------------
  Future<List<SaleModel>> fetchSales() async {
    try {
      final response = await _dio.get('/sales/');

      final data = response.data;
      return (data['results'] as List)
          .map((e) => SaleModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sales: $e');
    }
  }

  // ---------------- CREATE ----------------
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      final response = await _dio.post(
        '/sales/',
        data: sale.toJson(),
      );

      return SaleModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create sale: $e');
    }
  }

  // ---------------- UPDATE ----------------
  Future<SaleModel> updateSale(SaleModel sale) async {
    try {
      final response = await _dio.put(
        '/sales/${sale.id}/',
        data: sale.toJson(),
      );

      return SaleModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update sale: $e');
    }
  }

  // ---------------- DELETE ----------------
  Future<void> deleteSale(int id) async {
    try {
      await _dio.delete('/sales/$id/');
    } catch (e) {
      throw Exception('Failed to delete sale: $e');
    }
  }
}
