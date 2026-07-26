// app/modules/sale_return/sale_return_controller.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';

class ReturnedItemEntry {
  final SaleModel sale;
  final SaleItemModel item;
  ReturnedItemEntry({required this.sale, required this.item});
}

class SaleReturnController extends GetxController {
  final SalesController salesController = Get.find();

  final searchText = ''.obs;
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refresh_();
  }

  Future<void> refresh_() async {
    isLoading.value = true;
    await salesController.fetchSales();
    isLoading.value = false;
  }

  /// All returned items across all sales, newest first
  List<ReturnedItemEntry> get returnedEntries {
    final list = <ReturnedItemEntry>[];
    for (final sale in salesController.sales) {
      for (final item in sale.items) {
        if (item.hasReturn) {
          list.add(ReturnedItemEntry(sale: sale, item: item));
        }
      }
    }
    list.sort((a, b) {
      final da = a.item.returnedAt ?? DateTime(2000);
      final db = b.item.returnedAt ?? DateTime(2000);
      return db.compareTo(da); // newest first
    });
    return list;
  }

  List<ReturnedItemEntry> get filteredEntries {
    final q = searchText.value.toLowerCase();
    if (q.isEmpty) return returnedEntries;
    return returnedEntries.where((e) {
      return e.sale.customerName.toLowerCase().contains(q) ||
          e.item.itemName.toLowerCase().contains(q) ||
          (e.sale.billNo ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Sales that have at least one item with remaining_quantity > 0 (returnable)
  List<SaleModel> get returnableSales {
    return salesController.sales
        .where((s) => s.items.any((i) => i.remainingQuantity > 0))
        .toList();
  }

  Future<bool> processReturn({
    required SaleModel sale,
    required SaleItemModel item,
    required int quantity,
    String? reason,
  }) async {
    final success = await salesController.returnSaleItem(
      saleId: sale.id!,
      saleItemId: item.id!,
      quantity: quantity,
      reason: reason,
    );
    if (success) await refresh_();
    return success;
  }
}
