import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';

class PurchaseService {
  final Dio _dio = ApiService.dio;

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  Future<List<PurchaseModel>> getPurchases() async {
    final res = await _dio.get("/purchases/");
    
    return _extractList(res.data)
        .map((e) => PurchaseModel.fromJson(e))
        .toList();

  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final res = await _dio.post(
      "/purchases/",
      data: purchase.toJson(),
    );
    return PurchaseModel.fromJson(res.data);
  }

  Future<PurchaseModel> updatePurchase(PurchaseModel purchase) async {
    if (purchase.id == null) throw Exception("Purchase ID required for update");
    final res = await _dio.put(
      "/purchases/${purchase.id}/",
      data: purchase.toJson(),
    );
    return PurchaseModel.fromJson(res.data);
  }

  Future<void> deletePurchase(int id) async {
    await _dio.delete("/purchases/$id/");
  }
}
