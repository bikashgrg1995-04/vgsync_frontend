import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/models/purchase_model.dart';
import '../../data/repositories/purchase_repository.dart';

class PurchaseController extends GetxController {
  final PurchaseRepository purchaseRepository;
  final GlobalController globalController = Get.find<GlobalController>();
  final ItemController _itemController = Get.find<ItemController>();

  PurchaseController({required this.purchaseRepository});

  var purchases = <PurchaseModel>[].obs;
  var isLoading = false.obs;

  // Form controllers
  final supplierController = TextEditingController();
  final dateController = TextEditingController();
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    try {
      isLoading.value = true;
      purchases.value = await purchaseRepository.fetchPurchases();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPurchase() async {
    final purchase = PurchaseModel(
      supplier: int.parse(supplierController.text),
      date: dateController.text,
      items: [
        PurchaseItemModel(
          item: int.parse(itemController.text),
          quantity: int.parse(quantityController.text),
          price: double.parse(priceController.text),
        ),
      ],
    );
    print(purchase.toJson());

    await purchaseRepository.addPurchase(purchase);

    print(purchase.toJson());

    await fetchPurchases();
    await _itemController.fetchItems();
    globalController.triggerRefresh();
    _itemController.triggerRefresh();

    Get.back();
  }

  Future<void> updatePurchase(PurchaseModel purchase) async {
    final payload = {
      "supplier": int.parse(supplierController.text),
      "date": dateController.text,
      "items": [
        {
          "item": int.parse(itemController.text),
          "quantity": int.parse(quantityController.text),
          "price": double.parse(priceController.text),
        }
      ]
    };

    await purchaseRepository.editPurchase(
      purchase.id!,
      payload,
    );

    await fetchPurchases();
    await _itemController.fetchItems();
    globalController.triggerRefresh();
    _itemController.triggerRefresh();
    Get.back();
    Get.back();
  }

  Future<void> deletePurchase(int id) async {
    await purchaseRepository.removePurchase(id);
    purchases.removeWhere((p) => p.id == id);

    await fetchPurchases();
    await _itemController.fetchItems();
    globalController.triggerRefresh();
    _itemController.triggerRefresh();
  }

  void fillForm(PurchaseModel purchase) {
    supplierController.text = purchase.supplier.toString();
    dateController.text = purchase.date;

    if (purchase.items.isNotEmpty) {
      itemController.text = purchase.items.first.item.toString();
      quantityController.text = purchase.items.first.quantity.toString();
      priceController.text = purchase.items.first.price.toString();
    }
  }

  // -----------------------------
// Dialog helpers (same pattern as Customer & Item)
// -----------------------------

  void openAddPurchaseDialog() {
    clearForm();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Purchase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: addPurchase,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void openEditPurchaseDialog(PurchaseModel purchase) {
    fillForm(purchase);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Purchase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => updatePurchase(purchase),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void clearForm() {
    supplierController.clear();
    dateController.clear();
    itemController.clear();
    quantityController.clear();
    priceController.clear();
  }
}
