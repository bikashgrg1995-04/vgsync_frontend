import 'package:dio/dio.dart';
import '../models/purchase_model.dart';
import 'api_service.dart';

class PurchaseService {
  final Dio _dio = ApiService.dio;

  Future<List<PurchaseModel>> getPurchases() async {
    final res = await _dio.get("/purchases/");
    final data = res.data;

    if (data != null && data['results'] != null && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => PurchaseModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final res = await _dio.post("/purchases/", data: purchase.toJson());
    return PurchaseModel.fromJson(res.data);
  }

  Future<PurchaseModel> updatePurchase(PurchaseModel purchase) async {
    final res =
        await _dio.put("/purchases/${purchase.id}/", data: purchase.toJson());
    return PurchaseModel.fromJson(res.data);
  }

  Future<void> deletePurchase(int id) async {
    await _dio.delete("/purchases/$id/");
  }
}
