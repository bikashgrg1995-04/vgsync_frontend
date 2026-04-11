import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService orderService;

  OrderRepository({required this.orderService});

  // Fetch all orders
  Future<List<OrderModel>> getOrders() {
    return orderService.getOrders();
  }

  // Create a new order
  Future<OrderModel> create(OrderModel order) {
    return orderService.createOrder(order);
  }

  // Update an existing order
  Future<OrderModel> update(OrderModel order) {
    return orderService.updateOrder(order);
  }

  // Delete an order
  Future<void> delete(int id) {
    return orderService.deleteOrder(id);
  }
}
