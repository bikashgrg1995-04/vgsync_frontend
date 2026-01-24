import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_form_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final StockController stockCtrl = Get.find<StockController>();
  final OrderController orderCtrl = Get.find<OrderController>();
  late final OrderFormController formCtrl;

  @override
  void initState() {
    super.initState();
    formCtrl = Get.find<OrderFormController>();

    if (stockCtrl.stocks.isNotEmpty) {
      formCtrl.fillFromOrder(widget.order);
    }

    ever(stockCtrl.stocks, (_) {
      if (formCtrl.items.isEmpty && stockCtrl.stocks.isNotEmpty) {
        formCtrl.fillFromOrder(widget.order);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${widget.order.customerName}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.sw(0.014))),
            SizedBox(height: SizeConfig.sh(0.01)),
            Text("Contact: ${widget.order.contactNo}",
                style: TextStyle(fontSize: SizeConfig.sw(0.012))),
            SizedBox(height: SizeConfig.sh(0.01)),
            Text("Vehicle: ${widget.order.vehicleModel}",
                style: TextStyle(fontSize: SizeConfig.sw(0.012))),
            SizedBox(height: SizeConfig.sh(0.01)),
            Text(
                "Order Date: ${widget.order.orderDate.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: SizeConfig.sw(0.012))),
            SizedBox(height: SizeConfig.sh(0.02)),
             Text(
                "Status: ${widget.order.status.capitalizeFirst}",
                style: TextStyle(fontSize: SizeConfig.sw(0.012))),
            SizedBox(height: SizeConfig.sh(0.02)),

            // Add Item Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  if (!formCtrl.isModified.value) {
                    return const SizedBox.shrink();
                  }
                  return Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save Order"),
                      onPressed: _saveOrder,
                    ),
                  );
                }),
                SizedBox(width: SizeConfig.sw(0.02)),
                ElevatedButton.icon(
                    onPressed: _openStockPicker,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item")),
              ],
            ),

            SizedBox(height: SizeConfig.sh(0.01)),

            // Items Table
            _buildItemHeader(),
            Expanded(
              child: Obx(() => ListView.builder(
                  itemCount: formCtrl.items.length,
                  itemBuilder: (_, index) {
                    final item = formCtrl.items[index];
                    return buildItemRow(item, index);
                  })),
            ),

            SizedBox(height: SizeConfig.sh(0.02)),

            // Totals
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => Container(
                    width: SizeConfig.sw(0.35),
                    padding: EdgeInsets.all(SizeConfig.sw(0.02)),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAmountRow("Total Amount", formCtrl.totalAmount,
                            isBold: true),
                        SizedBox(height: SizeConfig.sh(0.008)),
                        _buildAmountRow("Advance Paid",
                            double.tryParse(formCtrl.advanceCtrl.text) ?? 0),
                        Divider(height: SizeConfig.sh(0.02)),
                        _buildAmountRow("Remaining", formCtrl.remainingAmount,
                            isBold: true, valueColor: Colors.red),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helper for Amount Rows ----------------
  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ---------------- Item Header ----------------
  Widget _buildItemHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Center(
                  child: Text("SN",
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          const Expanded(
              child:
                  Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
              width: 70,
              child: Center(
                  child: Text("Qty",
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(width: SizeConfig.sw(0.02)),
          SizedBox(
              width: 90,
              child: Center(
                  child: Text("Rate",
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(width: SizeConfig.sw(0.02)),
          SizedBox(
              width: 90,
              child: Center(
                  child: Text("Total",
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  void _saveOrder() async {
    final order = formCtrl.getOrderModel(id: widget.order.id);

    try {
      await orderCtrl.updateOrder(order);
      //AppSnackbar.success("Order updated successfully!");
      formCtrl.clearModifiedFlag(); // 🔑 reset modification flag
      
    } catch (e) {
     // AppSnackbar.error("Failed to update order.");
    }
  }

  // ---------------- Item Row ----------------
  Widget buildItemRow(OrderItemForm item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Center(child: Text("${index + 1}"))),
          Expanded(
              child: Text(item.stock.name, overflow: TextOverflow.ellipsis)),
          SizedBox(
            width: 70,
            height: 36,
            child: TextField(
              controller: item.qtyCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.02)),
          SizedBox(
            width: 90,
            height: 36,
            child: TextField(
              controller: item.rateCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.02)),
          SizedBox(
            width: 90,
            height: 36,
            child: Center(
              child: Obx(() => Text(item.total.value.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.w600))),
            ),
          ),
          SizedBox(
            width: 36,
            child: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => formCtrl.removeItem(index)),
          ),
        ],
      ),
    );
  }

  // ---------------- Stock Picker ----------------
  void _openStockPicker() async {
    final searchCtrl = TextEditingController();

    final Result? selected = await showDialog<Result>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Stock"),
        content: SizedBox(
          width: SizeConfig.sw(0.5),
          height: SizeConfig.sh(0.6),
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                    hintText: "Search stock...",
                    prefixIcon: Icon(Icons.search)),
                onChanged: (_) => (context as Element).markNeedsBuild(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  final filtered = stockCtrl.stocks
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(searchCtrl.text.toLowerCase()))
                      .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text("No stock found"));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text("Available: ${s.stock}"),
                        onTap: () {
                          Navigator.pop(context, s);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      final existingIndex =
          formCtrl.items.indexWhere((e) => e.stock.id == selected.id);
      if (existingIndex != -1) {
        _showUpdateItemDialog(existingIndex);
      } else {
        formCtrl.addItem(selected);
      }
    }
  }

  // ---------------- Update Existing Item ----------------
  void _showUpdateItemDialog(int index) {
    final item = formCtrl.items[index];
    final qtyCtrl = TextEditingController(text: item.qtyCtrl.text);
    final rateCtrl = TextEditingController(text: item.rateCtrl.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Item: ${item.stock.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField(qtyCtrl, "Quantity", Icons.add_chart,
                keyboardType: TextInputType.number),
            buildTextField(rateCtrl, "Rate", Icons.money_outlined,
                keyboardType: TextInputType.number)
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                item.qtyCtrl.text = qtyCtrl.text;
                item.rateCtrl.text = rateCtrl.text;
                formCtrl.items.refresh();
                Navigator.pop(context);
               // AppSnackbar.success("Item updated");
              },
              child: const Text("Save")),
        ],
      ),
    );
  }
}
