import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/item_detail_page.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/app/wigdets/file_upload.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/stock_model.dart';
import 'stock_controller.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  final StockController stockController = Get.find<StockController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final GlobalController globalController = Get.find<GlobalController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stockController.fetchStocks();
    });
  }

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
                Expanded(
                  flex: 3, // search gets more space
                  child: TextField(
                    controller: stockController.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search stocks...',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => stockController.stocks.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: stockController.refreshStock,
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Import',
                  icon: Icons.upload_file,
                  onPressed: () {
                    FileUploadDialog.show(
                      context: context,
                      title: 'Import Stock Excel',
                      endpoint: '/stock/excel-upload/',
                      fileKey: 'file',
                      allowedExtensions: ['xls', 'xlsx'],
                      onSuccess: () async {
                        await stockController.fetchStocks();
                        await categoryController.fetchCategories();
                        globalController
                            .triggerRefresh(DashboardRefreshType.stock);
                      },
                    );
                  },
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(
              child: Obx(() {
                if (stockController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query =
                    stockController.searchController.text.toLowerCase();
                final filtered = stockController.stocks.where((s) {
                  return s.name.toLowerCase().contains(query) ||
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
                            onPressed: (_) => stockController.deleteStock(
                                context, stock.id ?? 0),
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
                            'Item No: ${stock.itemNo} | Stock: ${stock.stock} | Selling Price: Rs. ${stock.salePrice}',
                            style: TextStyle(fontSize: SizeConfig.sw(0.008)),
                          ),
                          onTap: () {
                            Get.to(() => StockDetailPage(stockId: stock.id!));
                          },
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

  void openAddDialog() {
    // _injectCategoryController();
    stockController.clearForm();
    _showStockDialog(isEditMode: false);
  }

  void openEditDialog(Result stock) {
    // _injectCategoryController();
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
            width: SizeConfig.sw(0.2),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditMode ? 'Edit Stock' : 'Add Stock',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),
                  buildTextField(stockController.itemNoController, "Item No *",
                      Icons.confirmation_number),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                      stockController.nameController, "Name *", Icons.label),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(stockController.modelController, "Model",
                      Icons.model_training),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  Obx(() {
                    final selectedId =
                        stockController.categorySelectController.text.isNotEmpty
                            ? int.tryParse(
                                stockController.categorySelectController.text)
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
                          stockController.categorySelectController.text =
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
                    stockController.stockQtyController,
                    "Stock",
                    Icons.inventory,
                    keyboardType: TextInputType.number, // numeric keyboard
                  ),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                    stockController.purchasePriceController,
                    "Purchase Price",
                    Icons.price_change,
                    keyboardType: TextInputType.number, // numeric keyboard
                  ),
                  SizedBox(height: SizeConfig.sh(0.015)),
                  buildTextField(
                    stockController.salePriceController,
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
                      if (isEditMode)
                        TextButton(
                          onPressed: () {
                            if (stock != null) {
                              stockController.deleteStock(
                                  context, stock.id ?? 0);
                            }
                            Get.back();
                          },
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      SizedBox(height: SizeConfig.sw(0.008)),
                      ElevatedButton(
                        onPressed: () async {
                          if (isEditMode && stock != null) {
                            await stockController.updateStock(stock);
                            Get.back(closeOverlays: true);
                            DesktopToast.show(
                              'Stock updated successfully',
                              backgroundColor: Colors.greenAccent,
                            );
                          } else {
                            await stockController.addStock();
                            Get.back(closeOverlays: true);
                            DesktopToast.show(
                              'Stock added successfully',
                              backgroundColor: Colors.greenAccent,
                            );
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
}
