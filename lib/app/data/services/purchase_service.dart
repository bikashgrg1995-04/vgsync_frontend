import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  final Dio _dio = ApiService.dio;

  Future<List<PurchaseModel>> getPurchases() async {
    final res = await _dio.get('/purchases/');

    final List data = res.data['results'];
    return data.map((e) => PurchaseModel.fromJson(e)).toList();
  }

  Future<PurchaseModel> getPurchase(int id) async {
    final res = await _dio.get('/purchases/$id/');
    return PurchaseModel.fromJson(res.data);
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final res = await _dio.post('/purchases/', data: purchase.toJson());
    print(res.data);
    return PurchaseModel.fromJson(res.data);
  }

  Future<PurchaseModel> updatePurchase(
      int id, Map<String, dynamic> data) async {
    print(id);
    print(data);
    final res = await _dio.patch('/purchases/$id/', data: data);
    print(res.data);

    return PurchaseModel.fromJson(res.data);
  }

  Future<void> deletePurchase(int id) async {
    await _dio.delete('/purchases/$id/');
  }
}
