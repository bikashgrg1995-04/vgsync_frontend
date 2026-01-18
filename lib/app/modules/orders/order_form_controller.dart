import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

/// ================= Order Item Form =================
class OrderItemForm {
  Result stock;
  TextEditingController qtyCtrl;
  TextEditingController rateCtrl;

  // 🔑 Reactive total
  RxDouble total = 0.0.obs;

  OrderItemForm({
    required this.stock,
    int qty = 1,
    double? rate,
  })  : qtyCtrl = TextEditingController(text: qty.toString()),
        rateCtrl =
            TextEditingController(text: (rate ?? stock.salePrice).toString()) {
    _calculateTotal();

    // Update total whenever qty or rate changes
    qtyCtrl.addListener(_calculateTotal);
    rateCtrl.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    total.value = (double.tryParse(rateCtrl.text) ?? stock.salePrice) *
        (int.tryParse(qtyCtrl.text) ?? 1);
  }

  void dispose() {
    qtyCtrl.dispose();
    rateCtrl.dispose();
  }
}

/// ================= Order Form Controller =================
class OrderFormController extends GetxController {
  Rxn<DateTime> orderDate = Rxn<DateTime>();
  final customerCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final advanceCtrl = TextEditingController();

  final items = <OrderItemForm>[].obs;

  RxBool isModified = false.obs; // 🔑 tracks changes

  bool isInitializing = false; // 🔑

  // 🔑 StockController (from OrderBinding)
  final StockController stockCtrl = Get.find<StockController>();

  @override
  void onInit() {
    super.onInit();

    // Listen for changes in customer, contact, vehicle, advance
    customerCtrl.addListener(_markModified);
    contactCtrl.addListener(_markModified);
    vehicleCtrl.addListener(_markModified);
    advanceCtrl.addListener(_markModified);

    items.listen((_) => _markModified());
  }

  void _markModified() {
    if (isInitializing) return; // 🔑 ignore initial fill
    isModified.value = true;
  }

  // ---------------- Calculations ----------------
  double get totalAmount => items.fold(0, (sum, i) => sum + i.total.value);

  double get remainingAmount =>
      totalAmount - (double.tryParse(advanceCtrl.text) ?? 0);

  // ---------------- Item Ops ----------------
  void addItem(Result stock) {
    // prevent duplicate items
    if (items.any((e) => e.stock.id == stock.id)) {
      DesktopToast.show(
        'Item is aleardy added',
        backgroundColor: Colors.redAccent,
      );
    }
    items.add(OrderItemForm(stock: stock));
    _markModified(); // 🔑 mark order as modified
    DesktopToast.show(
      'Item added.',
      backgroundColor: Colors.greenAccent,
    );
  }

  void removeItem(int index) {
    items[index].dispose();
    _markModified(); // 🔑 mark order as modified
    items.removeAt(index);
  }

  void updateItem(int index, int qty, double rate) {
    final item = items[index];
    item.qtyCtrl.text = qty.toString();
    item.rateCtrl.text = rate.toString();
    items.refresh();
    _markModified();
  }

  void clearModifiedFlag() {
    isModified.value = false;
  }

  // ---------------- Clear ----------------
  void clearForm() {
    orderDate.value = DateTime.now();
    customerCtrl.clear();
    contactCtrl.clear();
    vehicleCtrl.clear();
    advanceCtrl.clear();
    for (final i in items) {
      i.dispose();
    }
    items.clear();
  }

  // ---------------- Build OrderModel ----------------
  OrderModel getOrderModel({int id = 0}) {
    return OrderModel(
      id: id,
      orderDate: orderDate.value ?? DateTime.now(),
      customerName: customerCtrl.text,
      contactNo: contactCtrl.text,
      vehicleModel: vehicleCtrl.text,
      items: items
          .map(
            (i) => OrderItemModel(
              id: 0,
              item: i.stock.id ?? 0,
              quantity: int.tryParse(i.qtyCtrl.text) ?? 1,
              rate: double.tryParse(i.rateCtrl.text) ?? i.stock.salePrice,
              totalPrice: i.total.value,
            ),
          )
          .toList(),
      totalAmount: totalAmount,
      advance: double.tryParse(advanceCtrl.text) ?? 0,
      remainingAmount: remainingAmount,
    );
  }

  void fillFromOrder(OrderModel order) {
    isInitializing = true; // start initialization

    orderDate.value = order.orderDate;
    customerCtrl.text = order.customerName;
    contactCtrl.text = order.contactNo;
    vehicleCtrl.text = order.vehicleModel;
    advanceCtrl.text = order.advance.toString();

    items.clear();

    for (final i in order.items) {
      final Result stock = stockCtrl.stocks.firstWhere(
        (s) => s.id == i.item,
        orElse: () => Result(
          id: i.item,
          name: "Item ${i.item}",
          group: "",
          model: "",
          category: 0,
          stock: 0,
          purchasePrice: 0,
          salePrice: i.rate,
          image: null,
          itemNo: "",
        ),
      );

      items.add(OrderItemForm(
        stock: stock,
        qty: i.quantity,
        rate: i.rate,
      ));
    }

    isInitializing = false; // end initialization
    isModified.value = false; // ensure no modifications yet
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
