import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

/// ================= Order Item Form =================
class OrderItemForm {
  Result stock;
  TextEditingController qtyCtrl;
  TextEditingController rateCtrl;

  OrderItemForm({
    required this.stock,
    int qty = 1,
    double? rate,
  })  : qtyCtrl = TextEditingController(text: qty.toString()),
        rateCtrl =
            TextEditingController(text: (rate ?? stock.salePrice).toString());

  double get total =>
      (double.tryParse(rateCtrl.text) ?? stock.salePrice) *
      (int.tryParse(qtyCtrl.text) ?? 1);
}

/// ================= Order Form Controller =================
class OrderFormController extends GetxController {
  final customerCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final advanceCtrl = TextEditingController();

  final items = <OrderItemForm>[].obs;

  // 🔑 StockController (from OrderBinding)
  final StockController stockCtrl = Get.find<StockController>();

  // ---------------- Calculations ----------------
  double get totalAmount => items.fold(0, (sum, i) => sum + i.total);

  double get remainingAmount =>
      totalAmount - (double.tryParse(advanceCtrl.text) ?? 0);

  // ---------------- Item Ops ----------------
  void addItem(Result stock) {
    // prevent duplicate items
    if (items.any((e) => e.stock.id == stock.id)) return;
    items.add(OrderItemForm(stock: stock));
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  // ---------------- Clear ----------------
  void clearForm() {
    customerCtrl.clear();
    contactCtrl.clear();
    vehicleCtrl.clear();
    advanceCtrl.clear();
    items.clear();
  }

  // ---------------- Build OrderModel ----------------
  OrderModel getOrderModel({int id = 0}) {
    return OrderModel(
      id: id,
      customerName: customerCtrl.text,
      contactNo: contactCtrl.text,
      vehicleModel: vehicleCtrl.text,
      orderDate: DateTime.now(),
      items: items
          .map(
            (i) => OrderItemModel(
              id: 0,
              item: i.stock.id ?? 0,
              quantity: int.tryParse(i.qtyCtrl.text) ?? 1,
              rate: double.tryParse(i.rateCtrl.text) ?? i.stock.salePrice,
              totalPrice: i.total,
            ),
          )
          .toList(),
      totalAmount: totalAmount,
      advance: double.tryParse(advanceCtrl.text) ?? 0,
      remainingAmount: remainingAmount,
    );
  }

  // ---------------- EDIT MODE (🔥 FIXED) ----------------
  void fillFromOrder(OrderModel order) {
    customerCtrl.text = order.customerName;
    contactCtrl.text = order.contactNo;
    vehicleCtrl.text = order.vehicleModel;
    advanceCtrl.text = order.advance.toString();

    items.clear();

    for (final i in order.items) {
      // 🔑 Find stock from StockController
      final Result stock = stockCtrl.stocks.firstWhere(
        (s) => s.id == i.item,
        orElse: () => Result(
          id: i.item,
          name: "Item ${i.item}", // fallback only if stock not loaded
          group: "",
          model: "",
          category: 0,
          stock: 0,
          purchasePrice: 0,
          salePrice: i.rate,
          vat: 0,
          image: null,
          itemNo: "",
        ),
      );

      items.add(
        OrderItemForm(
          stock: stock,
          qty: i.quantity,
          rate: i.rate,
        ),
      );
    }
  }

  @override
  void onClose() {
    customerCtrl.dispose();
    contactCtrl.dispose();
    vehicleCtrl.dispose();
    advanceCtrl.dispose();
    for (final i in items) {
      i.qtyCtrl.dispose();
      i.rateCtrl.dispose();
    }
    super.onClose();
  }
}
