import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/repositories/order_repository.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

class OrderController extends GetxController {
  final OrderRepository orderRepository;

  OrderController({required this.orderRepository});

  // ---------------- Reactive variables ----------------
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  final searchController = TextEditingController();
  final GlobalController globalController = Get.find<GlobalController>();

  // ---------------- Fetch Orders ----------------
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final result = await orderRepository.getOrders();
      orders.assignAll(result);
    } catch (e) {
       DesktopToast.show("Failed to fetch orders.",  backgroundColor: Colors.redAccent,);
      
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
      globalController.triggerRefresh(DashboardRefreshType.order);
    } catch (e) {
      DesktopToast.show(
        "Failed to add order.",
        backgroundColor: Colors.redAccent,
      );
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
 globalController.triggerRefresh(DashboardRefreshType.order);
    } catch (e) {
      DesktopToast.show(
        "Failed to update order.",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Order ----------------
  Future<void> deleteOrder(BuildContext context, int id) async {
    ConfirmDialog.show(context,
        title: "Delete Order",
        message: "Are you sure you want to delete this order?",
        onConfirm: () async {
      try {
        isLoading.value = true;
        await orderRepository.delete(id);
        orders.removeWhere((o) => o.id == id);
         globalController.triggerRefresh(DashboardRefreshType.order);
      } catch (e) {
        DesktopToast.show(
          "Failed to delete order.",
          backgroundColor: Colors.redAccent,
        );
      } finally {
        isLoading.value = false;
      }
    });
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

  Future<void> refreshOrders() async {
    // 🔥 RESET FILTERS

    searchController.clear();

    await fetchOrders();
  }
}
