import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_detail_page.dart';
import 'package:vgsync_frontend/app/modules/orders/order_form_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/app/wigdets/file_upload.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../wigdets/custom_form_dialog.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final OrderController controller = Get.find<OrderController>();
  final ScrollController _itemScrollCtrl = ScrollController();
  GlobalController globalCtrl = Get.find<GlobalController>();

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
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search orders...',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => controller.orders.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.refreshOrders,
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Import',
                  icon: Icons.upload_file,
                  onPressed: () {
                    FileUploadDialog.show(
                      context: context,
                      title: 'Import Orders (Excel)',
                      endpoint: '/upload/order-excel/',
                      fileKey: 'file',
                      allowedExtensions: ['xls', 'xlsx'],
                      onSuccess: () async {
                        await controller.fetchOrders();
                        globalCtrl.triggerRefresh(DashboardRefreshType.order);
                      },
                    );
                  },
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
              ],
            ),

            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Status Filter Toggle ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                filterButton('All', 'all'),
                filterButton('Pending', 'pending'),
                filterButton('Received', 'received'),
                filterButton('Completed', 'completed'),
              ],
            ),

            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Orders List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = controller.searchController.text.toLowerCase();
                final filtered = controller
                    .searchOrders(query)
                    .where((o) => controller.selectedStatus.value == 'all'
                        ? true
                        : o.status == controller.selectedStatus.value)
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final order = filtered[index];
                    return buildOrderTile(order, index);
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
        width: 0.6,
        height: 0.9,
        content: _buildDialogContent(formCtrl),
        onSave: () {
          final orderCtrl = Get.find<OrderController>();
          final newOrder = formCtrl.getOrderModel(id: order?.id ?? 0);

          if (isEditMode) {
            orderCtrl.updateOrder(newOrder);
            Get.back(closeOverlays: true);
            DesktopToast.show(
              "Order updated successfully.",
              backgroundColor: Colors.greenAccent,
            );
          } else {
            orderCtrl.addOrder(newOrder);
            Get.back(closeOverlays: true);
            DesktopToast.show(
              "Order added successfully.",
              backgroundColor: Colors.greenAccent,
            );
          }
        },
        onDelete: isEditMode
            ? () {
                controller.deleteOrder(context, order.id);
                Get.back(closeOverlays: true);
                DesktopToast.show(
                  "Order deleted successfully.",
                  backgroundColor: Colors.greenAccent,
                );
              }
            : null,
      ),
      barrierDismissible: false,
    );
  }

  // ---------------- Status Filter Button ----------------
  Widget filterButton(String label, String statusValue) {
    return Obx(() {
      final selected = controller.selectedStatus.value == statusValue;
      return Padding(
        padding: EdgeInsets.only(right: SizeConfig.sw(0.01)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? Colors.blue : Colors.grey.shade300,
            foregroundColor: selected ? Colors.white : Colors.black,
          ),
          onPressed: () => controller.selectedStatus.value = statusValue,
          child: Text(label),
        ),
      );
    });
  }

  // ---------------- Order Tile ----------------
  Widget buildOrderTile(OrderModel order, int index) {
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
              onPressed: (_) => controller.deleteOrder(context, order.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.sw(0.008)),
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
              'Vehicle: ${order.vehicleModel} | Total: ${order.totalAmount} | Remaining: ${order.remainingAmount} | Status: ${order.status.toUpperCase()}',
              style: TextStyle(fontSize: SizeConfig.sw(0.008)),
            ),
            onTap: () => Get.to(() => OrderDetailPage(order: order)),
          ),
        ),
      ),
    );
  }

  // ---------------- Remaining code for items and order dialog ----------------
  Widget _buildDialogContent(OrderFormController formCtrl) {
    return SizedBox(
      height: SizeConfig.sh(0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Date
          SizedBox(
            width: SizeConfig.sw(0.3),
            child: CommonDatePicker(
              label: "Order Date",
              selectedDate: formCtrl.orderDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            ),
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          // Customer & Vehicle
          Row(
            children: [
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: buildTextField(
                    formCtrl.customerCtrl, 'Customer Name', Icons.person),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: buildTextField(
                    formCtrl.contactCtrl, 'Contact No', Icons.phone),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          // Vehicle, Advance & Status
          Row(
            children: [
              SizedBox(
                width: SizeConfig.sw(0.2),
                child: buildTextField(
                    formCtrl.vehicleCtrl, 'Vehicle Model', Icons.bike_scooter),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(
                width: SizeConfig.sw(0.15),
                child: buildTextField(
                    formCtrl.advanceCtrl, 'Advance Amount', Icons.money,
                    keyboardType: TextInputType.number),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              Obx(
                () => Row(
                  children: [
                    const Text("Status:"),
                    SizedBox(width: SizeConfig.sw(0.02)),
                    DropdownButton<String>(
                      value: formCtrl.status.value,
                      items: const [
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'received', child: Text('Received')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completed')),
                      ],
                      onChanged: (v) {
                        if (v != null) formCtrl.status.value = v;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          _buildItemHeader(),
          SizedBox(
            height: SizeConfig.sh(0.3),
            child: Obx(
              () => Scrollbar(
                controller: _itemScrollCtrl,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _itemScrollCtrl,
                  itemCount: formCtrl.items.length,
                  itemBuilder: (_, i) {
                    final item = formCtrl.items[i];
                    return buildItemRow(formCtrl, item, i);
                  },
                ),
              ),
            ),
          ),
          // Totals & Add Item
          Row(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Item"),
                  onPressed: () => _openStockPicker(formCtrl),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              Obx(() => Text(
                  "Total: ${formCtrl.totalAmount.toStringAsFixed(2)} | Remaining: ${formCtrl.remainingAmount.toStringAsFixed(2)}")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
              width: 40,
              child: Text("SN",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              child:
                  Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
              width: 70,
              child: Text("Qty",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 8),
          SizedBox(
              width: 90,
              child: Text("Rate",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 8),
          SizedBox(
              width: 90,
              child: Text("Total",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  void _openStockPicker(OrderFormController formCtrl) async {
    final stockCtrl = Get.find<StockController>();
    final searchCtrl = TextEditingController();

    final Result? selected = await showDialog<Result>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Stock"),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: "Search stock...",
                  prefixIcon: Icon(Icons.search),
                ),
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
                  if (filtered.isEmpty)
                    return const Center(child: Text("No stock found"));
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text("Available: ${s.stock}"),
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

    if (selected != null) {
      formCtrl.addItem(selected);
    }
  }

  Widget buildItemRow(
      OrderFormController formCtrl, OrderItemForm item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 40,
              child: Text('${index + 1}.', textAlign: TextAlign.center)),
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
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  border: OutlineInputBorder()),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            height: 36,
            child: TextField(
              controller: item.rateCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  border: OutlineInputBorder()),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
              width: 90,
              height: 36,
              child: Center(
                  child: Text(item.total.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w600)))),
          SizedBox(
              width: 36,
              child: IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => formCtrl.removeItem(index))),
        ],
      ),
    );
  }
}
