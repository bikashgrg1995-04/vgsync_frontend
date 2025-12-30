import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository orderRepository;

  OrderController({required this.orderRepository});

  // ---------------- Reactive variables ----------------
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  // ---------------- Fetch Orders ----------------
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final result = await orderRepository.getOrders();
      orders.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add Order ----------------
  Future<void> addOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      final newOrder = await orderRepository.create(order);
      orders.add(newOrder);
      Get.back(); // close dialog/page
      Get.snackbar('Success', 'Order added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Update Order ----------------
  Future<void> updateOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      final updatedOrder = await orderRepository.update(order);
      final index = orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) orders[index] = updatedOrder;
      Get.back();
      Get.snackbar('Success', 'Order updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Order ----------------
  Future<void> deleteOrder(int id) async {
    try {
      isLoading.value = true;
      await orderRepository.delete(id);
      orders.removeWhere((o) => o.id == id);
      Get.snackbar('Success', 'Order deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Search Orders ----------------
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return orders;
    final q = query.toLowerCase();
    return orders.where((o) {
      return o.customerName.toLowerCase().contains(q) ||
          o.contactNo.toLowerCase().contains(q) ||
          o.vehicleModel.toLowerCase().contains(q);
    }).toList();
  }
}
