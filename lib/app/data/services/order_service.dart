import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final Dio _dio = ApiService.dio;

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  // Fetch all orders
  Future<List<OrderModel>> getOrders() async {
    final res = await _dio.get("/orders/");

     return _extractList(res.data)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  // Create new order
  Future<OrderModel> createOrder(OrderModel order) async {
    final res = await _dio.post("/orders/", data: order.toJson());
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  // Update existing order
  Future<OrderModel> updateOrder(OrderModel order) async {
    final res = await _dio.put("/orders/${order.id}/", data: order.toJson());
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  // Delete order
  Future<void> deleteOrder(int id) async {
    await _dio.delete("/orders/$id/");
  }
}
