import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_form_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../wigdets/custom_form_dialog.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final OrderController controller = Get.find<OrderController>();
  final searchController = TextEditingController();
  final ScrollController _itemScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            // ---------------- Search + Refresh ----------------
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search orders...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => controller.orders.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                SizedBox(
                  width: SizeConfig.sw(0.12),
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchOrders,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------------- Orders List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = searchController.text.toLowerCase();
                final filtered = controller.searchOrders(query);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final order = filtered[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(order.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openEditDialog(order),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.deleteOrder(order.id),
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
                                BorderRadius.circular(SizeConfig.sw(0.008)),
                          ),
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
                              order.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.sw(0.012),
                              ),
                            ),
                            subtitle: Text(
                              'Vehicle: ${order.vehicleModel} | Total: ${order.totalAmount} | Remaining: ${order.remainingAmount}',
                              style: TextStyle(fontSize: SizeConfig.sw(0.008)),
                            ),
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
        label: const Text('Add Order'),
      ),
    );
  }

  // ---------------- Add/Edit ----------------
  void openAddDialog() => _openOrderDialog();
  void openEditDialog(OrderModel order) => _openOrderDialog(order: order);

  void _openOrderDialog({OrderModel? order}) {
    final formCtrl = Get.put(OrderFormController(), permanent: false);
    final isEditMode = order != null;

    formCtrl.clearForm();
    if (isEditMode) formCtrl.fillFromOrder(order);

    Get.dialog(
      CustomFormDialog(
        title: isEditMode ? "Edit Order" : "Add Order",
        isEditMode: isEditMode,
        width: 0.5,
        height: 0.68,
        content: _buildDialogContent(formCtrl),
        onSave: () {
          final orderCtrl = Get.find<OrderController>();
          final newOrder = formCtrl.getOrderModel(id: order?.id ?? 0);

          if (isEditMode) {
            orderCtrl.updateOrder(newOrder);
          } else {
            orderCtrl.addOrder(newOrder);
          }

          Get.back(); // CLOSE DIALOG FIRST
        },
        onDelete: isEditMode
            ? () {
                controller.deleteOrder(order.id);
                Get.back();
              }
            : null,
      ),
      barrierDismissible: false,
    ).then((_) {
      if (Get.isRegistered<OrderFormController>()) {
        Get.delete<OrderFormController>(); // SAFE cleanup
      }
    });
  }

  Widget _buildDialogContent(OrderFormController formCtrl) {
    return SizedBox(
      height: SizeConfig.sh(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------- Customer & Vehicle ---------
          Row(
            children: [
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: TextField(
                  controller: formCtrl.customerCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: TextField(
                  controller: formCtrl.contactCtrl,
                  decoration: const InputDecoration(labelText: 'Contact No'),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          Row(
            children: [
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: TextField(
                  controller: formCtrl.vehicleCtrl,
                  decoration: const InputDecoration(labelText: 'Vehicle Model'),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: TextField(
                  controller: formCtrl.advanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Advance Amount'),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),

          // --------- Items List ---------
          Expanded(
            child: Obx(() => Scrollbar(
                  controller: _itemScrollCtrl,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _itemScrollCtrl,
                    itemCount: formCtrl.items.length,
                    itemBuilder: (_, i) {
                      final item = formCtrl.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(item.stock.name.isNotEmpty
                                      ? item.stock.name
                                      : "Item ${item.stock.id}")),
                              SizedBox(
                                width: SizeConfig.sw(0.06),
                                child: TextField(
                                  controller: item.qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: 'Qty'),
                                  onChanged: (_) => formCtrl.items.refresh(),
                                ),
                              ),
                              SizedBox(width: SizeConfig.sw(0.02)),
                              SizedBox(
                                width: SizeConfig.sw(0.06),
                                child: TextField(
                                  controller: item.rateCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: 'Rate'),
                                  onChanged: (_) => formCtrl.items.refresh(),
                                ),
                              ),
                              SizedBox(width: SizeConfig.sw(0.02)),
                              SizedBox(
                                  width: SizeConfig.sw(0.06),
                                  child: Text(item.total.toStringAsFixed(2))),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => formCtrl.removeItem(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
          ),

          // --------- Add Item Button ---------
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final stockCtrl = Get.find<StockController>();
                final TextEditingController searchCtrl =
                    TextEditingController();
                Result? selected = await showDialog(
                  context: context,
                  builder: (_) => StatefulBuilder(
                    builder: (_, setState) => AlertDialog(
                      title: const Text("Select Stock"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: searchCtrl,
                            decoration: const InputDecoration(
                                labelText: "Search Stock"),
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(
                            height: 200,
                            width: double.maxFinite,
                            child: Obx(() {
                              final filtered = stockCtrl.stocks
                                  .where((s) => s.name
                                      .toLowerCase()
                                      .contains(searchCtrl.text.toLowerCase()))
                                  .toList();
                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (_, i) {
                                  final s = filtered[i];
                                  return ListTile(
                                    title: Text(s.name),
                                    subtitle: Text("Stock: ${s.stock}"),
                                    onTap: () => Navigator.pop(context, s),
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
                if (selected != null) formCtrl.addItem(selected);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),
          ),

          const SizedBox(height: 10),

          // --------- Total & Remaining ---------
          Obx(() => Text(
              "Total: ${formCtrl.totalAmount.toStringAsFixed(2)} | Remaining: ${formCtrl.remainingAmount.toStringAsFixed(2)}")),
        ],
      ),
    );
  }
}
