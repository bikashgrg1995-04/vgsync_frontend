import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'stock_controller.dart';

class StockDetailPage extends StatelessWidget {
  final int stockId;
  final StockController controller = Get.find<StockController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  StockDetailPage({super.key, required this.stockId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Result? stock = controller.getStockById(stockId);

      /// If stock deleted
      if (stock == null) {
        return Scaffold(
          appBar: AppBar(title: const Text("Stock Details")),
          body: const Center(
            child: Text(
              "Stock not found",
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(stock.name),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Basic Information"),
                  _infoRow("Item No", stock.itemNo),
                  _infoRow("Name", stock.name),
                  _infoRow("Group", stock.group),
                  _infoRow("Model", stock.model),

                  const Divider(height: 32),

                  _sectionTitle("Stock & Pricing"),
                  _infoRow("Stock Quantity", stock.stock.toString()),
                  _infoRow("Purchase Price",
                      "Rs. ${stock.purchasePrice.toStringAsFixed(2)}"),
                  _infoRow("Sale Price (VAT)",
                      "Rs. ${stock.salePrice.toStringAsFixed(2)}"),

                  const Divider(height: 32),

                  _sectionTitle("Category"),
                  _infoRow(
                      "Category ",
                      categoryController.categories
                          .where((a) => a.id == stock.category)
                          .first
                          .name
                          .toString()),

                  const SizedBox(height: 24),

                  /// ACTION BUTTONS (Optional bottom buttons)
                  Row(
                    children: [
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: const Text("Edit Stock"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            controller.fillForm(stock);
                            openEditDialog(context, stock);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            controller.deleteStock(context, stock.id ?? 0);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void openEditDialog(BuildContext context, Result stock) {
    // _injectCategoryController();
    controller.fillForm(stock);
    _showStockDialog(context, stock: stock);
  }

  void _showStockDialog(BuildContext context, {Result? stock}) {
    final categoryCtrl = Get.find<CategoryController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: SizeConfig.sw(0.2),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Stock',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),
                  buildTextField(controller.itemNoController, "Item No *",
                      Icons.confirmation_number),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                      controller.nameController, "Name *", Icons.label),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(controller.modelController, "Model",
                      Icons.model_training),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  Obx(() {
                    final selectedId = controller
                            .categorySelectController.text.isNotEmpty
                        ? int.tryParse(controller.categorySelectController.text)
                        : null;
                    return DropdownButtonFormField<int>(
                      value: selectedId,
                      items: categoryCtrl.categories
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final selected = categoryCtrl.categories
                              .firstWhere((c) => c.id == value);
                          controller.categorySelectController.text =
                              selected.id.toString();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    );
                  }),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                    controller.stockQtyController,
                    "Stock",
                    Icons.inventory,
                    keyboardType: TextInputType.number, // numeric keyboard
                  ),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                    controller.purchasePriceController,
                    "Purchase Price",
                    Icons.price_change,
                    keyboardType: TextInputType.number, // numeric keyboard
                  ),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                    controller.salePriceController,
                    "Sale Price (13% VAT)",
                    Icons.sell,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (stock != null) {
                            controller.deleteStock(context, stock.id ?? 0);
                          }
                          Get.back(closeOverlays: true);
                          DesktopToast.show(
                            'Stock deleted successfully',
                            backgroundColor: Colors.greenAccent,
                          );
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                      SizedBox(height: SizeConfig.sw(0.008)),
                      ElevatedButton(
                        onPressed: stock == null
                            ? null
                            : () async {
                                await controller
                                    .updateStock(stock); // ✅ force unwrap SAFE
                                Get.back(closeOverlays: true);
                                DesktopToast.show(
                                  'Stock updated successfully',
                                  backgroundColor: Colors.greenAccent,
                                );
                              },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
