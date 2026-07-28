// app/modules/purchase_return/purchase_return_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_return_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class PurchaseReturnPage extends StatelessWidget {
  const PurchaseReturnPage({super.key});

  static const _bg = AppColors.background;
  static const _surface = AppColors.surface;
  static const _primary = AppColors.primary;
  static const _warning = AppColors.warning;
  static const _danger = AppColors.error;
  static const _success = AppColors.success;
  static const _textDark = AppColors.textPrimary;
  static const _textMid = AppColors.textSecondary;
  static const _border = AppColors.divider;
  static const _shadow = Color(0x0F000000);

  String _supplierName(SupplierController supplierController, int supplierId) {
    final s = supplierController.suppliers
        .firstWhereOrNull((s) => s.id == supplierId);
    return s?.name ?? 'Supplier #$supplierId';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final controller = Get.put(PurchaseReturnController());
    final supplierController = Get.find<SupplierController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Returns',
            style: TextStyle(
                fontSize: SizeConfig.res(4.5),
                fontWeight: FontWeight.w700,
                color: _textDark)),
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: _bg,
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track and process purchase item returns',
                style:
                    TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildHeader(controller),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildSummaryCard(controller), // 👈 new
            SizedBox(height: SizeConfig.sh(0.018)),
            Expanded(child: _buildReturnList(controller, supplierController)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _openNewReturnDialog(context, controller, supplierController),
        backgroundColor: _warning,
        icon: const Icon(Icons.keyboard_return_rounded, color: Colors.white),
        label: const Text('New Return',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(PurchaseReturnController controller) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: SizeConfig.sh(0.055),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: TextField(
                style:
                    TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: _textMid, size: SizeConfig.res(5)),
                  hintText: 'Search by supplier name or bill number...',
                  hintStyle:
                      TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                ),
                onChanged: (v) => controller.searchText.value = v,
              ),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : controller.refresh_,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.014),
                      vertical: SizeConfig.sh(0.013)),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: SizeConfig.res(4.5), color: _primary),
                      SizedBox(width: SizeConfig.sw(0.005)),
                      Text('Refresh',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2),
                              fontWeight: FontWeight.w600,
                              color: _primary)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReturnList(PurchaseReturnController controller,
      SupplierController supplierController) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      final entries = controller.filteredEntries;
      if (entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_return_rounded,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No returns yet',
                  style:
                      TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: entries.length,
        itemBuilder: (_, i) => _returnTile(entries[i], supplierController),
      );
    });
  }

  Widget _returnTile(
      ReturnedPurchaseItemEntry entry, SupplierController supplierController) {
    final item = entry.item;
    final purchase = entry.purchase;
    final refundAmount = item.returnedQuantity * item.price;

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: SizeConfig.sw(0.006),
            height: SizeConfig.sh(0.08),
            decoration: BoxDecoration(
              color: item.isFullyReturned ? _danger : _warning,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.014)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.itemName ?? '',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.8),
                              fontWeight: FontWeight.w700,
                              color: _textDark),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.01),
                          vertical: SizeConfig.sh(0.005)),
                      decoration: BoxDecoration(
                        color: (item.isFullyReturned ? _danger : _warning)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (item.isFullyReturned ? _danger : _warning)
                                .withOpacity(0.3)),
                      ),
                      child: Text(
                        item.isFullyReturned ? 'FULL RETURN' : 'PARTIAL RETURN',
                        style: TextStyle(
                            fontSize: SizeConfig.res(2.6),
                            fontWeight: FontWeight.w700,
                            color: item.isFullyReturned ? _danger : _warning),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.sh(0.006)),
                // 👇 Bill No + Customer name row
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: SizeConfig.res(3.2), color: _textMid),
                    SizedBox(width: SizeConfig.sw(0.004)),
                    Text('Bill #${purchase.id ?? "-"}',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.2),
                            fontWeight: FontWeight.w600,
                            color: _textMid)),
                    SizedBox(width: SizeConfig.sw(0.014)),
                    Icon(Icons.local_shipping_outlined,
                        size: SizeConfig.res(3.2), color: _textMid),
                    SizedBox(width: SizeConfig.sw(0.004)),
                    Text('Supplier:',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.2),
                            fontWeight: FontWeight.w600,
                            color: _textMid)),
                    SizedBox(width: SizeConfig.sw(0.004)),
                    Expanded(
                      child: Text(
                          _supplierName(supplierController, purchase.supplier),
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                if (item.returnedAt != null) ...[
                  SizedBox(height: SizeConfig.sh(0.004)),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: SizeConfig.res(3.2), color: _textMid),
                      SizedBox(width: SizeConfig.sw(0.004)),
                      Text(item.returnedAt!.toIso8601String().split('T')[0],
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
                    ],
                  ),
                ],
                if (item.returnReason != null &&
                    item.returnReason!.isNotEmpty) ...[
                  SizedBox(height: SizeConfig.sh(0.006)),
                  Text('Reason: ${item.returnReason}',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          color: _textMid,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.returnedQuantity} / ${item.quantity} returned',
                  style:
                      TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
              SizedBox(height: SizeConfig.sh(0.004)),
              Text('Rs. ${refundAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: SizeConfig.res(4),
                      fontWeight: FontWeight.w800,
                      color: _danger)),
            ],
          ),
        ],
      ),
    );
  }

  // ── New Return Dialog ─────────────────────────────────────────────────────
  void _openNewReturnDialog(
      BuildContext context,
      PurchaseReturnController controller,
      SupplierController supplierController) {
    final purchaseSearchCtrl = TextEditingController();
    final RxString dialogSearchQuery = ''.obs;
    final Rxn<PurchaseModel> selectedPurchase = Rxn<PurchaseModel>();
    final Rxn<PurchaseItemModel> selectedItem = Rxn<PurchaseItemModel>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: SizeConfig.sw(0.4),
          height: SizeConfig.sh(0.7),
          padding: EdgeInsets.all(SizeConfig.res(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.keyboard_return_rounded,
                      color: _warning, size: SizeConfig.res(5)),
                  SizedBox(width: SizeConfig.sw(0.01)),
                  Expanded(
                    child: Text('Process Return',
                        style: TextStyle(
                            fontSize: SizeConfig.res(4.5),
                            fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back()),
                ],
              ),
              const Divider(),
              SizedBox(height: SizeConfig.sh(0.01)),
              Obx(() {
                if (selectedPurchase.value == null) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: purchaseSearchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search by customer name or bill no...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (value) => dialogSearchQuery.value =
                              value.toLowerCase().trim(),
                        ),
                        SizedBox(height: SizeConfig.sh(0.012)),
                        Expanded(
                          child: Obx(() {
                            final q =
                                dialogSearchQuery.value.toLowerCase().trim();
                            final list =
                                controller.returnablePurchases.where((p) {
                              if (q.isEmpty) return true;
                              final name =
                                  _supplierName(supplierController, p.supplier)
                                      .toLowerCase();
                              final billNumber =
                                  (p.id ?? '').toString().toLowerCase();
                              return name.contains(q) || billNumber.contains(q);
                            }).toList();
                            if (list.isEmpty) {
                              return Center(
                                  child: Text('No returnable purchases found',
                                      style: TextStyle(color: _textMid)));
                            }
                            return ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (_, i) {
                                final p = list[i];
                                return ListTile(
                                  title: Text(_supplierName(
                                      supplierController, p.supplier)),
                                  subtitle: Text(
                                      'Bill #${p.id ?? "-"} · ${p.date.toIso8601String().split("T")[0]}'),
                                  onTap: () => selectedPurchase.value = p,
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }

                final purchase = selectedPurchase.value!;
                final returnableItems = purchase.items
                    .where((i) => i.remainingQuantity > 0)
                    .toList();

                if (selectedItem.value == null) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => selectedPurchase.value = null,
                            ),
                            Text(
                                _supplierName(
                                    supplierController, purchase.supplier),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: SizeConfig.res(3.6))),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: returnableItems.length,
                            itemBuilder: (_, i) {
                              final item = returnableItems[i];
                              return ListTile(
                                title: Text(item.itemName ?? ''),
                                subtitle: Text(
                                    'Remaining: ${item.remainingQuantity} / ${item.quantity}'),
                                trailing: Text(
                                    'Rs. ${item.price.toStringAsFixed(2)}'),
                                onTap: () => selectedItem.value = item,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = selectedItem.value!;
                final qtyCtrl = TextEditingController(text: '1');
                final reasonCtrl = TextEditingController();

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => selectedItem.value = null,
                          ),
                          Expanded(
                            child: Text(item.itemName ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: SizeConfig.res(3.6))),
                          ),
                        ],
                      ),
                      Text(
                          'Remaining: ${item.remainingQuantity} of ${item.quantity}',
                          style: TextStyle(
                              color: _textMid, fontSize: SizeConfig.res(3))),
                      SizedBox(height: SizeConfig.sh(0.02)),
                      TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Return Quantity',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: SizeConfig.sh(0.015)),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Reason (optional)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final qty = int.tryParse(qtyCtrl.text) ?? 0;
                            if (qty <= 0) {
                              DesktopToast.show('Enter a valid quantity',
                                  backgroundColor: _danger);
                              return;
                            }
                            if (qty > item.remainingQuantity) {
                              DesktopToast.show(
                                  'Only ${item.remainingQuantity} left to return',
                                  backgroundColor: _danger);
                              return;
                            }
                            final success = await controller.processReturn(
                              purchase: purchase,
                              item: item,
                              quantity: qty,
                              reason: reasonCtrl.text,
                            );
                            if (success) Get.back();
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Confirm Return',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _warning,
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.sh(0.015)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryCard(PurchaseReturnController controller) {
    return Obx(() {
      final entries = controller.filteredEntries;
      final totalItemsReturned =
          entries.fold<int>(0, (sum, e) => sum + e.item.returnedQuantity);
      final totalAmount = entries.fold<double>(
          0.0, (sum, e) => sum + (e.item.returnedQuantity * e.item.price));

      return Container(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            _summaryTile(
              icon: Icons.inventory_2_outlined,
              label: 'Total Items Returned',
              value: '$totalItemsReturned',
              color: _warning,
            ),
            Container(
              width: 1,
              height: SizeConfig.sh(0.05),
              color: _border,
              margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.02)),
            ),
            _summaryTile(
              icon: Icons.currency_exchange_rounded,
              label: 'Total Purchase Return',
              value: 'Rs. ${totalAmount.toStringAsFixed(2)}',
              color: _danger,
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2.5)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: SizeConfig.res(5), color: color),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: SizeConfig.res(2.8), color: _textMid)),
              SizedBox(height: SizeConfig.sh(0.003)),
              Text(value,
                  style: TextStyle(
                      fontSize: SizeConfig.res(4),
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
