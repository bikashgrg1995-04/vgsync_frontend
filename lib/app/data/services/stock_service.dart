import 'package:dio/dio.dart';
import '../models/stock_model.dart';
import 'api_service.dart';

class StockService {
  final Dio _dio = ApiService.dio;

  Future<List<Result>> getStocks() async {
    final res = await _dio.get("/stocks/");
    final data = res.data;

    if (data != null && data['results'] != null && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => Result.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<Result> createStock(Result stock) async {
    final res = await _dio.post("/stocks/", data: stock.toJson());

    // Handle validation errors
    if (res.statusCode != 201 && res.data is Map<String, dynamic>) {
      throw Exception("Validation error: ${res.data}");
    }

    if (res.data is Map<String, dynamic>) {
      return Result.fromJson(res.data);
    } else if (res.data is List) {
      return Result.fromJson(res.data[0]);
    } else {
      throw Exception("Unexpected API response: ${res.data}");
    }
  }

  Future<Result> updateStock(Result stock) async {
    final res = await _dio.put("/stocks/${stock.id}/", data: stock.toJson());

    if (res.statusCode != 200 && res.data is Map<String, dynamic>) {
      throw Exception("Validation error: ${res.data}");
    }

    if (res.data is Map<String, dynamic>) {
      return Result.fromJson(res.data);
    } else if (res.data is List) {
      return Result.fromJson(res.data[0]);
    } else {
      throw Exception("Unexpected API response: ${res.data}");
    }
  }

  Future<void> deleteStock(int id) async {
    await _dio.delete("/stocks/$id/");
  }
}
