import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import '../models/item_model.dart';

class ItemService {
  final Dio _dio = ApiService.dio;

  // Fetch all items (paginated API)
  Future<List<ItemModel>> getItems() async {
    final res = await _dio.get("/items/");

    if (res.data != null && res.data['results'] != null) {
      final List<dynamic> dataList = res.data['results'] as List<dynamic>;
      return dataList.map((e) => ItemModel.fromJson(e)).toList();
    }

    return [];
  }

  Future<ItemModel> getItem(int id) async {
    final res = await _dio.get("/items/$id/");
    return ItemModel.fromJson(res.data);
  }

  Future<ItemModel> createItem(ItemModel item) async {
    final res = await _dio.post("/items/", data: item.toJson());
    return ItemModel.fromJson(res.data);
  }

  Future<ItemModel> updateItem(ItemModel item) async {
    final res = await _dio.put("/items/${item.id}/", data: item.toJson());
    return ItemModel.fromJson(res.data);
  }

  Future<void> deleteItem(int id) async {
    await _dio.delete("/items/$id/");
  }
}
