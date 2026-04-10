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
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';
import '../../wigdets/custom_form_dialog.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final OrderController controller = Get.find<OrderController>();
  final ScrollController _itemScrollCtrl = ScrollController();
  final GlobalController globalCtrl = Get.find<GlobalController>();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _success  = AppColors.success;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _info     = AppColors.info;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  @override
  void initState() {
    super.initState();
    controller.fetchOrders();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return _success;
      case 'received':  return _info;
      case 'pending':   return _warning;
      default:          return _textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Order',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600)),
        backgroundColor: _primary,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.sh(0.015)),
            _pageTitle(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.016)),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ── Page title ─────────────────────────────────────────────────────────────
  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Orders',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Track and manage customer orders',
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: SizeConfig.sh(0.055),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                      hintText: 'Search orders...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (_) => controller.orders.refresh(),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              _headerBtn(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                color: _primary,
                onPressed: controller.refreshOrders,
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          Obx(() => Row(
                children: [
                  _filterChip('All',       'all',       _primary),
                  _filterChip('Pending',   'pending',   _warning),
                  _filterChip('Received',  'received',  _info),
                  _filterChip('Completed', 'completed', _success),
                ],
              )),
        ],
      ),
    );
  }

  Widget _headerBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.013)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5), color: color),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, Color color) {
    final isSelected = controller.selectedStatus.value == value;
    return Padding(
      padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
      child: GestureDetector(
        onTap: () => controller.selectedStatus.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.010)),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _surface : color)),
        ),
      ),
    );
  }

  // ── List ────────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      final query = controller.searchController.text.toLowerCase();
      final filtered = controller
          .searchOrders(query)
          .where((o) => controller.selectedStatus.value == 'all'
              ? true
              : o.status == controller.selectedStatus.value)
          .toList();

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No orders found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: filtered.length,
        itemBuilder: (_, index) => _orderTile(filtered[index], index),
      );
    });
  }

  Widget _orderTile(OrderModel order, int index) {
    final statusColor = _statusColor(order.status);
    final isPending = order.remainingAmount > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      child: Slidable(
        key: ValueKey(order.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => openEditDialog(order),
              backgroundColor: _warning,
              foregroundColor: _surface,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (_) => controller.deleteOrder(context, order.id),
              backgroundColor: _danger,
              foregroundColor: _surface,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Get.to(() => OrderDetailPage(order: order)),
          child: Container(
            padding: EdgeInsets.all(SizeConfig.res(4)),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
              boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                // accent bar
                Container(
                  width: SizeConfig.sw(0.006),
                  height: SizeConfig.sh(0.09),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.014)),
                // index avatar
                Container(
                  width: SizeConfig.sw(0.04),
                  height: SizeConfig.sw(0.04),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _primary.withOpacity(0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.2),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
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
                            child: Text(order.customerName,
                                style: TextStyle(
                                    fontSize: SizeConfig.res(4),
                                    fontWeight: FontWeight.w700,
                                    color: _textDark),
                                overflow: TextOverflow.ellipsis),
                          ),
                          _statusPill(order.status, statusColor),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      Row(
                        children: [
                          Icon(Icons.bike_scooter_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(order.vehicleModel,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2), color: _textMid)),
                          SizedBox(width: SizeConfig.sw(0.016)),
                          Icon(Icons.calendar_today_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(order.orderDate.toIso8601String().split('T')[0],
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2), color: _textMid)),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.01)),
                      Row(
                        children: [
                          _amountChip('Total', order.totalAmount, _textDark),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip('Advance', order.advance, _success),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip('Remaining', order.remainingAmount,
                              isPending ? _warning : _success),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _textMid, size: SizeConfig.res(5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.010), vertical: SizeConfig.sh(0.005)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status.capitalizeFirst ?? status,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2)),
    );
  }

  Widget _amountChip(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.res(2.6), color: _textMid)),
        Text('Rs. ${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: SizeConfig.res(3.4),
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
  void openAddDialog() => _openOrderDialog();
  void openEditDialog(OrderModel order) => _openOrderDialog(order: order);

  void _openOrderDialog({OrderModel? order}) {
    final formCtrl = Get.put(OrderFormController(), permanent: false);
    final isEdit = order != null;
    formCtrl.clearForm();
    if (isEdit) formCtrl.fillFromOrder(order);

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Order' : 'Add Order',
        isEditMode: isEdit,
        width: 0.6,
        height: 0.9,
        content: _buildDialogContent(formCtrl),
        onSave: () {
          final newOrder = formCtrl.getOrderModel(id: order?.id ?? 0);
          if (isEdit) {
            controller.updateOrder(newOrder);
            Get.back(closeOverlays: true);
            DesktopToast.show('Order updated successfully', backgroundColor: _success);
          } else {
            controller.addOrder(newOrder);
            Get.back(closeOverlays: true);
            DesktopToast.show('Order added successfully', backgroundColor: _success);
          }
        },
        onDelete: isEdit
            ? () {
                controller.deleteOrder(context, order.id);
                Get.back(closeOverlays: true);
                DesktopToast.show('Order deleted successfully', backgroundColor: _success);
              }
            : null,
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDialogContent(OrderFormController formCtrl) {
    return SizedBox(
      height: SizeConfig.sh(0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          SizedBox(
            width: SizeConfig.sw(0.3),
            child: CommonDatePicker(
              label: 'Order Date',
              selectedDate: formCtrl.orderDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            ),
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          Row(
            children: [
              SizedBox(width: SizeConfig.sw(0.2),
                  child: _field(formCtrl.customerCtrl, 'Customer Name', Icons.person_outline_rounded)),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(width: SizeConfig.sw(0.2),
                  child: _field(formCtrl.contactCtrl, 'Contact No', Icons.phone_outlined,
                      keyboardType: TextInputType.phone)),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          Row(
            children: [
              SizedBox(width: SizeConfig.sw(0.2),
                  child: _field(formCtrl.vehicleCtrl, 'Vehicle Model', Icons.bike_scooter_outlined)),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(width: SizeConfig.sw(0.15),
                  child: _field(formCtrl.advanceCtrl, 'Advance Amount', Icons.payments_outlined,
                      keyboardType: TextInputType.number)),
              SizedBox(width: SizeConfig.sw(0.02)),
              SizedBox(width: SizeConfig.sw(0.15),
                  child: _styledDropdown<String>(
                    label: 'Status',
                    value: formCtrl.status.value,
                    onChanged: (val) => formCtrl.status.value = val ?? 'pending',
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'received', child: Text('Received')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    ],
                  )),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          _dialogItemHeader(),
          SizedBox(
            height: SizeConfig.sh(0.3),
            child: Obx(() => Scrollbar(
                  controller: _itemScrollCtrl,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _itemScrollCtrl,
                    itemCount: formCtrl.items.length,
                    itemBuilder: (_, i) => _dialogItemRow(formCtrl, formCtrl.items[i], i),
                  ),
                )),
          ),
          SizedBox(height: SizeConfig.sh(0.012)),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openStockPicker(formCtrl),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.013)),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: SizeConfig.res(4.5), color: _primary),
                      SizedBox(width: SizeConfig.sw(0.006)),
                      Text('Add Item',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4),
                              fontWeight: FontWeight.w600,
                              color: _primary)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.02)),
              Obx(() => Row(
                    children: [
                      _totalBadge('Total', formCtrl.totalAmount, _primary),
                      SizedBox(width: SizeConfig.sw(0.016)),
                      _totalBadge('Remaining', formCtrl.remainingAmount,
                          formCtrl.remainingAmount > 0 ? _warning : _success),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalBadge(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.008)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
          Text('Rs. ${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: SizeConfig.res(3.6),
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _dialogItemHeader() {
    return Container(
      height: SizeConfig.sh(0.05),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: SizeConfig.sw(0.035),
            child: Text('SN',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary)),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          Expanded(child: Text('Item', style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.07), child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(width: SizeConfig.sw(0.09), child: Text('Rate', textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(width: SizeConfig.sw(0.09), child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.036)),
        ],
      ),
    );
  }

  Widget _dialogItemRow(OrderFormController formCtrl, OrderItemForm item, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.008)),
      decoration: BoxDecoration(
        color: index.isEven ? _bg : _surface,
        border: Border(bottom: BorderSide(color: _border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: SizeConfig.sw(0.035),
            child: Text('${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          Expanded(
            child: Text(item.stock.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: SizeConfig.res(3.4), fontWeight: FontWeight.w600, color: _textDark)),
          ),
          SizedBox(
            width: SizeConfig.sw(0.07),
            height: SizeConfig.sh(0.042),
            child: TextField(
              controller: item.qtyCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
              decoration: _tableInputDecoration(),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(
            width: SizeConfig.sw(0.09),
            height: SizeConfig.sh(0.042),
            child: TextField(
              controller: item.rateCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
              decoration: _tableInputDecoration(),
              onChanged: (_) => formCtrl.items.refresh(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(
            width: SizeConfig.sw(0.09),
            child: Text('Rs. ${item.total.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: SizeConfig.res(3.2), fontWeight: FontWeight.w700, color: _primary)),
          ),
          SizedBox(
            width: SizeConfig.sw(0.036),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.delete_outline_rounded, size: SizeConfig.res(4.5), color: _danger),
              onPressed: () => formCtrl.removeItem(index),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _tableInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.sh(0.01), horizontal: SizeConfig.sw(0.004)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primary, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _border)),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        prefixIcon: Icon(icon, size: SizeConfig.res(4.5), color: _primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
      ),
    );
  }

  void _openStockPicker(OrderFormController formCtrl) async {
    final stockCtrl = Get.find<StockController>();
    final searchCtrl = TextEditingController();

    final StockModel? selected = await showDialog<StockModel>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Stock',
              style: TextStyle(fontSize: SizeConfig.res(4.5), fontWeight: FontWeight.w700, color: _textDark)),
          content: SizedBox(
            width: SizeConfig.sw(0.4),
            height: SizeConfig.sh(0.5),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border)),
                  child: TextField(
                    controller: searchCtrl,
                    style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Search by name or item no...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(height: SizeConfig.sh(0.012)),
                Expanded(
                  child: Builder(builder: (_) {
                    final filtered = stockCtrl.stocks
                        .where((s) =>
                            s.name.toLowerCase().contains(searchCtrl.text.toLowerCase()) ||
                            s.itemNo.toLowerCase().contains(searchCtrl.text.toLowerCase()))
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(
                          child: Text('No stock found',
                              style: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.5))));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        final stockColor = s.stock <= 0 ? _danger : s.stock <= 5 ? _warning : _success;
                        return Container(
                          margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.pop(context, s),
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.res(3)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name,
                                            style: TextStyle(
                                                fontSize: SizeConfig.res(3.6),
                                                fontWeight: FontWeight.w700,
                                                color: _textDark)),
                                        Text('No: ${s.itemNo}',
                                            style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.005)),
                                    decoration: BoxDecoration(
                                      color: stockColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Stock: ${s.stock}',
                                        style: TextStyle(
                                            fontSize: SizeConfig.res(3),
                                            fontWeight: FontWeight.w700,
                                            color: stockColor)),
                                  ),
                                ],
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
        ),
      ),
    );
    if (selected != null) formCtrl.addItem(selected);
  }
}