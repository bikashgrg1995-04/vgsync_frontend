import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/category_repository.dart';
import 'package:vgsync_frontend/app/data/services/category_service.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/stock_model.dart';
import 'stock_controller.dart';

class StockListPage extends StatelessWidget {
  StockListPage({super.key});

  final StockController stockController = Get.find<StockController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search stocks...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => stockController.stocks.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                SizedBox(
                  width: SizeConfig.sw(0.08),
                  child: ElevatedButton.icon(
                    onPressed: stockController.fetchStocks,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(
              child: Obx(() {
                if (stockController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = searchController.text.toLowerCase();
                final filtered = stockController.stocks.where((s) {
                  return s.name.toLowerCase().contains(query) ||
                      s.group.toLowerCase().contains(query) ||
                      s.model.toLowerCase().contains(query) ||
                      s.itemNo.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No stocks found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final stock = filtered[index];
                    return Slidable(
                      key: ValueKey(stock.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,
                        children: [
                          SlidableAction(
                            onPressed: (_) => openEditDialog(stock),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) =>
                                stockController.deleteStock(stock.id ?? 0),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.sw(0.008))),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(SizeConfig.sw(0.01)),
                          leading: CircleAvatar(
                            radius: SizeConfig.sw(0.03),
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.sw(0.02),
                              ),
                            ),
                          ),
                          title: Text(
                            stock.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: SizeConfig.sw(0.012),
                            ),
                          ),
                          subtitle: Text(
                            'Item No: ${stock.itemNo} | Stock: ${stock.stock} | Price: ${stock.salePrice}',
                            style: TextStyle(fontSize: SizeConfig.sw(0.008)),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
      ),
    );
  }

  void _injectCategoryController() {
    if (!Get.isRegistered<CategoryController>()) {
      Get.put(CategoryController(
          categoryRepository:
              CategoryRepository(categoryService: CategoryService())));
    }
  }

  void openAddDialog() {
    _injectCategoryController();
    stockController.clearForm();
    _showStockDialog(isEditMode: false);
  }

  void openEditDialog(Result stock) {
    _injectCategoryController();
    stockController.fillForm(stock);
    _showStockDialog(isEditMode: true, stock: stock);
  }

  void _showStockDialog({required bool isEditMode, Result? stock}) {
    final categoryCtrl = Get.find<CategoryController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditMode ? 'Edit Stock' : 'Add Stock',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      stockController.itemNoController, "Item No *"),
                  const SizedBox(height: 12),
                  _buildTextField(stockController.nameController, "Name *"),
                  // const SizedBox(height: 12),
                  // _buildTextField(stockController.groupController, "Group"),
                  const SizedBox(height: 12),
                  _buildTextField(stockController.modelController, "Model"),
                  const SizedBox(height: 12),
                  Obx(() {
                    final selectedId = stockController
                            .categoryController.text.isNotEmpty
                        ? int.tryParse(stockController.categoryController.text)
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
                          stockController.categoryController.text =
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

                  const SizedBox(height: 12),
                  _buildTextField(stockController.stockQtyController, "Stock",
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField(
                      stockController.purchasePriceController, "Purchase Price",
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField(
                      stockController.salePriceController, "Sale Price",
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField(stockController.vatController, "VAT (%)",
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      if (isEditMode)
                        TextButton(
                          onPressed: () {
                            if (stock != null) {
                              stockController.deleteStock(stock.id ?? 0);
                            }
                            Get.back();
                          },
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (isEditMode && stock != null) {
                            stockController.updateStock(stock);
                          } else {
                            stockController.addStock();
                          }
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
