import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

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
    final res = await _dio.post(
      "/purchases/",
      data: purchase.toJsonForApi(),
    );
    return PurchaseModel.fromJson(res.data);
  }

  Future<PurchaseModel> updatePurchase(PurchaseModel purchase) async {
    if (purchase.id == null) throw Exception("Purchase ID required for update");
    final res = await _dio.put(
      "/purchases/${purchase.id}/",
      data: purchase.toJsonForApi(),
    );
    return PurchaseModel.fromJson(res.data);
  }

  Future<void> deletePurchase(int id) async {
    await _dio.delete("/purchases/$id/");
  }
}
