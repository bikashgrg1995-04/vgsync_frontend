import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
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
      final StockModel? stock = controller.getStockById(stockId);

      if (stock == null) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(title: const Text("Stock Details")),
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "Stock not found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      final isLowStock = stock.stock <= 5;
      final isOutOfStock = stock.stock <= 0;

      final categoryName = () {
        try {
          return categoryController.categories
              .firstWhere((a) => a.id == stock.category)
              .name;
        } catch (_) {
          return 'N/A';
        }
      }();

      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black26),
            onPressed: () => Get.back(),
          ),
          title: Text(
            stock.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              tooltip: 'Edit',
              onPressed: () {
                controller.fillForm(stock);
                openEditDialog(context, stock);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => controller.deleteStock(context, stock.id),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Card ──────────────────────────────────────────
              _heroCard(stock, isOutOfStock, isLowStock),

              const SizedBox(height: 16),

              // ── Info + Pricing Row ─────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _basicInfoCard(stock)),
                  const SizedBox(width: 16),
                  Expanded(child: _pricingCard(stock)),
                ],
              ),

              const SizedBox(height: 16),

              // ── Category + Location Row ────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _categoryCard(categoryName)),
                  const SizedBox(width: 16),
                  Expanded(child: _locationCard(stock)),
                ],
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ─────────────────────────────────────
              _actionButtons(context, stock),
            ],
          ),
        ),
      );
    });
  }

  // ── HERO CARD ──────────────────────────────────────────────────────────────
  Widget _heroCard(StockModel stock, bool isOutOfStock, bool isLowStock) {
    Color stockColor = isOutOfStock
        ? Colors.red
        : isLowStock
            ? Colors.orange
            : Colors.green;

    String stockLabel = isOutOfStock
        ? 'Out of Stock'
        : isLowStock
            ? 'Low Stock'
            : 'In Stock';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          // Name + Item No
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Item No: ${stock.itemNo}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Stock badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stockColor.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  stock.stock.toString(),
                  style: TextStyle(
                    color: stockColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stockLabel,
                  style: TextStyle(color: stockColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BASIC INFO CARD ────────────────────────────────────────────────────────
  Widget _basicInfoCard(StockModel stock) {
    return _card(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      children: [
        _row('Item No', stock.itemNo),
        _row('Group', stock.group.isEmpty ? '—' : stock.group),
        _row('Model', stock.model?.isEmpty ?? true ? '—' : stock.model!),
      ],
    );
  }

  // ── PRICING CARD ───────────────────────────────────────────────────────────
  Widget _pricingCard(StockModel stock) {
    return _card(
      title: 'Pricing',
      icon: Icons.payments_outlined,
      children: [
        _row('Purchase Price', 'Rs. ${stock.purchasePrice.toStringAsFixed(2)}'),
        _row('Sale Price (VAT)', 'Rs. ${stock.salePrice.toStringAsFixed(2)}'),
        _row(
          'Vat Amount (13%)',
          'Rs. ${(stock.salePrice - stock.purchasePrice).toStringAsFixed(2)}',
          valueColor: Colors.green.shade700,
        ),
      ],
    );
  }

  // ── CATEGORY CARD ──────────────────────────────────────────────────────────
  Widget _categoryCard(String categoryName) {
    return _card(
      title: 'Category',
      icon: Icons.category_outlined,
      children: [
        _row('Category', categoryName),
      ],
    );
  }

  // ── LOCATION CARD ──────────────────────────────────────────────────────────
  Widget _locationCard(StockModel stock) {
    return _card(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        _row('Block / Shelf', stock.block?.isEmpty ?? true ? '—' : stock.block!),
      ],
    );
  }

  // ── ACTION BUTTONS ─────────────────────────────────────────────────────────
  Widget _actionButtons(BuildContext context, StockModel stock) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.deleteStock(context, stock.id),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.fillForm(stock);
              openEditDialog(context, stock);
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text('Edit Stock',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ── SHARED CARD WRAPPER ────────────────────────────────────────────────────
  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.indigo.shade400),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ── INFO ROW ───────────────────────────────────────────────────────────────
  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── EDIT DIALOG ────────────────────────────────────────────────────────────
  void openEditDialog(BuildContext context, StockModel stock) {
    controller.fillForm(stock);
    _showStockDialog(context, stock: stock);
  }

  void _showStockDialog(BuildContext context, {StockModel? stock}) {
    final categoryCtrl = Get.find<CategoryController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: SizeConfig.sw(0.35),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit_outlined,
                          color: Colors.indigo.shade600, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Stock',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Fields
                buildTextField(controller.itemNoController, "Item No *",
                    Icons.confirmation_number),
                SizedBox(height: SizeConfig.sh(0.015)),
                buildTextField(
                    controller.nameController, "Name *", Icons.label),
                SizedBox(height: SizeConfig.sh(0.015)),
                buildTextField(controller.modelController, "Model",
                    Icons.model_training),
                SizedBox(height: SizeConfig.sh(0.015)),

                // Category dropdown
                Obx(() {
                  final selectedId =
                      controller.categorySelectController.text.isNotEmpty
                          ? int.tryParse(
                              controller.categorySelectController.text)
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
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  );
                }),
                SizedBox(height: SizeConfig.sh(0.015)),

                buildTextField(
                  controller.stockQtyController,
                  "Stock Quantity",
                  Icons.inventory,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: SizeConfig.sh(0.015)),
                buildTextField(
                  controller.purchasePriceController,
                  "Purchase Price",
                  Icons.price_change,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: SizeConfig.sh(0.015)),
                buildTextField(
                  controller.salePriceController,
                  "Sale Price (13% VAT)",
                  Icons.sell,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: stock == null
                          ? null
                          : () async {
                              await controller.updateStock(stock);
                            },
                      icon: const Icon(Icons.save_outlined,
                          size: 18, color: Colors.white),
                      label: const Text('Save Changes',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}