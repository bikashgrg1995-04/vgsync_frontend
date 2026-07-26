// app/modules/purchase_return/purchase_return_controller.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';

class ReturnedPurchaseItemEntry {
  final PurchaseModel purchase;
  final PurchaseItemModel item;
  ReturnedPurchaseItemEntry({required this.purchase, required this.item});
}

class PurchaseReturnController extends GetxController {
  final PurchaseController purchaseController = Get.find();

  final searchText = ''.obs;
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refresh_();
  }

  Future<void> refresh_() async {
    isLoading.value = true;
    await purchaseController.fetchPurchases();
    isLoading.value = false;
  }

  List<ReturnedPurchaseItemEntry> get returnedEntries {
    final list = <ReturnedPurchaseItemEntry>[];
    for (final purchase in purchaseController.purchases) {
      for (final item in purchase.items) {
        if (item.hasReturn) {
          list.add(ReturnedPurchaseItemEntry(purchase: purchase, item: item));
        }
      }
    }
    list.sort((a, b) {
      final da = a.item.returnedAt ?? DateTime(2000);
      final db = b.item.returnedAt ?? DateTime(2000);
      return db.compareTo(da);
    });
    return list;
  }

  List<ReturnedPurchaseItemEntry> get filteredEntries {
    final q = searchText.value.toLowerCase();
    if (q.isEmpty) return returnedEntries;
    return returnedEntries.where((e) {
      return (e.item.itemName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Purchases with at least one item having remaining_quantity > 0
  List<PurchaseModel> get returnablePurchases {
    return purchaseController.purchases
        .where((p) => p.items.any((i) => i.remainingQuantity > 0))
        .toList();
  }

  Future<bool> processReturn({
    required PurchaseModel purchase,
    required PurchaseItemModel item,
    required int quantity,
    String? reason,
  }) async {
    final success = await purchaseController.returnPurchaseItem(
      purchaseId: purchase.id!,
      purchaseItemId: item.id,
      quantity: quantity,
      reason: reason,
    );
    if (success) await refresh_();
    return success;
  }
}
