import 'package:dio/dio.dart';
import '../models/stock_model.dart';
import 'api_service.dart';

class StockService {
  final Dio _dio = ApiService.dio;

  /// ================= GET ALL =================
  Future<List<StockModel>> getStocks() async {
    final res = await _dio.get("/stocks/");

    if (res.data is List) {
      return (res.data as List)
          .map((e) => StockModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// ================= CREATE =================
  Future<StockModel> createStock(StockModel stock) async {
    final res = await _dio.post("/stocks/", data: stock.toJson());

    if (res.statusCode != 201) {
      throw Exception("Validation error: ${res.data}");
    }

    return StockModel.fromJson(res.data);
  }

  /// ================= UPDATE =================
  Future<StockModel> updateStock(StockModel stock) async {
    final res = await _dio.put("/stocks/${stock.id}/", data: stock.toJson());

    if (res.statusCode != 200) {
      throw Exception("Validation error: ${res.data}");
    }

    return StockModel.fromJson(res.data);
  }

  /// ================= DELETE =================
  Future<void> deleteStock(int id) async {
    await _dio.delete("/stocks/$id/");
  }
}