import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_detail_page.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/purchase_model.dart';
import '../../data/models/stock_model.dart';
import 'purchase_controller.dart';
import '../../wigdets/custom_form_dialog.dart';
import '../../modules/stock/stock_controller.dart';
import '../../themes/app_colors.dart';
import 'package:vgsync_frontend/app/wigdets/file_upload.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseController controller = Get.find<PurchaseController>();
  final StockController stockController = Get.find<StockController>();
  final SupplierController supplierController = Get.find();
  final StaffController staffController = Get.find();
  final GlobalController globalController = Get.find();
  final ScrollController _itemScrollCtrl = ScrollController();

  // ── Color aliases ─────────────────────────────────────────────────────────
  static const _bg = AppColors.background;
  static const _surface = AppColors.surface;
  static const _primary = AppColors.primary;
  static const _success = AppColors.success;
  static const _warning = AppColors.warning;
  static const _danger = AppColors.error;
  static const _textDark = AppColors.textPrimary;
  static const _textMid = AppColors.textSecondary;
  static const _border = AppColors.divider;
  static const _shadow = Color(0x0F000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPurchases();
    });
  }

  // ── Status helpers ────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return _success;
      case 'partial':
        return _warning;
      default:
        return _danger;
    }
  }

  Color _statusBg(String status) => _statusColor(status).withOpacity(0.1);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.sh(0.02)),
            _buildPageTitle(),
            SizedBox(height: SizeConfig.sh(0.02)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(child: _buildPurchaseList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text(
          'Add Purchase',
          style:
              TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primary,
        elevation: 2,
      ),
    );
  }

  // ── Page title ─────────────────────────────────────────────────────────────
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchases',
          style: TextStyle(
            fontSize: SizeConfig.res(7),
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Manage and track all purchase records',
          style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid),
        ),
      ],
    );
  }

  // ── Header card ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.4), color: _textDark),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: _textMid, size: SizeConfig.res(5)),
                      hintText: 'Search purchases...',
                      hintStyle: TextStyle(
                          color: _textMid, fontSize: SizeConfig.res(3.4)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (_) => controller.purchases.refresh(),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              _headerButton(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onPressed: controller.refreshSales,
                color: _primary,
              ),
              SizedBox(width: SizeConfig.sw(0.008)),
    _headerButton(
      label: 'Import',
      icon: Icons.upload_file_outlined,
      onPressed: () {
        FileUploadDialog.show(
          context: context,
          title: 'Import Purchase Excel',
          endpoint: '/upload/purchase-excel/',
          fileKey: 'file',
          allowedExtensions: ['xls', 'xlsx'],
          onSuccess: () async {
            await controller.fetchPurchases();
            await stockController.fetchStocks();
            globalController.triggerRefresh(DashboardRefreshType.all);
          },
        );
      },
      color: _primary,
    ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.018)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateButton(),
              _buildStatusFilter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.014),
          vertical: SizeConfig.sh(0.013),
        ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.res(3.2),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton() {
    return Obx(() => GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.014),
              vertical: SizeConfig.sh(0.013),
            ),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primary.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: SizeConfig.res(4), color: _primary),
                SizedBox(width: SizeConfig.sw(0.006)),
                Text(
                  controller.filterSelectedDate.value == null
                      ? 'Select Date'
                      : controller.filterSelectedDate.value!
                          .toIso8601String()
                          .split('T')[0],
                  style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                if (controller.filterSelectedDate.value != null) ...[
                  SizedBox(width: SizeConfig.sw(0.006)),
                  GestureDetector(
                    onTap: () => controller.filterSelectedDate.value = null,
                    child: Icon(Icons.close_rounded,
                        size: SizeConfig.res(3.5), color: _primary),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildStatusFilter() {
    const statusOptions = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Paid', 'value': 'paid'},
      {'label': 'Partial', 'value': 'partial'},
      {'label': 'Not Paid', 'value': 'not_paid'},
    ];

    return Obx(() => Row(
          children: statusOptions.map((s) {
            final isSelected = controller.selectedStatus.value == s['value'];
            final color = s['value'] == 'paid'
                ? _success
                : s['value'] == 'partial'
                    ? _warning
                    : s['value'] == 'not_paid'
                        ? _danger
                        : _primary;
            return Padding(
              padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
              child: GestureDetector(
                onTap: () => controller.selectedStatus.value = s['value']!,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.012),
                    vertical: SizeConfig.sh(0.010),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: SizeConfig.res(3),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _surface : color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.filterSelectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.filterSelectedDate.value = picked;
  }

  // ── Purchase list ──────────────────────────────────────────────────────────
  Widget _buildPurchaseList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: _primary),
        );
      }

      List<PurchaseModel> filtered = controller.filteredPurchases(
        query: controller.searchController.text.toLowerCase(),
      );

      if (controller.filterSelectedDate.value != null) {
        filtered = filtered
            .where((p) =>
                p.date.year == controller.filterSelectedDate.value!.year &&
                p.date.month == controller.filterSelectedDate.value!.month &&
                p.date.day == controller.filterSelectedDate.value!.day)
            .toList();
      }

      if (controller.selectedStatus.value != 'all') {
        filtered = filtered
            .where((p) => p.status == controller.selectedStatus.value)
            .toList();
      }

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text(
                'No purchases found',
                style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(
            bottom: SizeConfig.sh(0.1), right: SizeConfig.sw(0.01)),
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final purchase = filtered[index];
          final supplier = supplierController.suppliers.firstWhere(
            (s) => s.id == purchase.supplier,
          );
          return Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
            child: Slidable(
              key: ValueKey(purchase.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.28,
                children: [
                  SlidableAction(
                    onPressed: (_) => _openEditDialog(purchase),
                    backgroundColor: AppColors.warning,
                    foregroundColor: _surface,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                  ),
                  SlidableAction(
                    onPressed: (_) =>
                        controller.deletePurchase(context, purchase.id ?? 0),
                    backgroundColor: _danger,
                    foregroundColor: _surface,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12)),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () =>
                    Get.to(() => PurchaseDetailPage(purchase: purchase)),
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.res(4)),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                    boxShadow: const [
                      BoxShadow(
                          color: _shadow, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      // ── Status accent bar ──────────────────────────────
                      Container(
                        width: SizeConfig.sw(0.006),
                        height: SizeConfig.sh(0.075),
                        decoration: BoxDecoration(
                          color: _statusColor(purchase.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: SizeConfig.sw(0.014)),

                      // ── Main info ──────────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  supplier.name,
                                  style: TextStyle(
                                    fontSize: SizeConfig.res(4),
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                                _statusPill(purchase.status),
                              ],
                            ),
                            SizedBox(height: SizeConfig.sh(0.006)),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: SizeConfig.res(3.2), color: _textMid),
                                SizedBox(width: SizeConfig.sw(0.004)),
                                Text(
                                  purchase.date.toIso8601String().split('T')[0],
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3.2),
                                      color: _textMid),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeConfig.sh(0.01)),
                            Row(
                              children: [
                                _amountChip(
                                  label: 'Total',
                                  value: purchase.netTotal,
                                  color: _textDark,
                                ),
                                SizedBox(width: SizeConfig.sw(0.02)),
                                _amountChip(
                                  label: 'Paid',
                                  value: purchase.paidAmount,
                                  color: _success,
                                ),
                                SizedBox(width: SizeConfig.sw(0.02)),
                                _amountChip(
                                  label: 'Remaining',
                                  value: purchase.remainingAmount,
                                  color: purchase.remainingAmount > 0
                                      ? _warning
                                      : _success,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Arrow ──────────────────────────────────────────
                      Icon(Icons.chevron_right_rounded,
                          color: _textMid, size: SizeConfig.res(5)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _statusPill(String status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.010),
        vertical: SizeConfig.sh(0.005),
      ),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: SizeConfig.res(2.8),
          fontWeight: FontWeight.w700,
          color: _statusColor(status),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _amountChip(
      {required String label, required double value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: SizeConfig.res(2.6), color: _textMid)),
        Text(
          'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: SizeConfig.res(3.4),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
  void _openAddDialog() => _openDialog();
  void _openEditDialog(PurchaseModel purchase) =>
      _openDialog(purchase: purchase);

  void _openDialog({PurchaseModel? purchase}) {
    final isEditMode = purchase != null;
    controller.clearForm();
    if (isEditMode) controller.populateForm(purchase);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => CustomFormDialog(
          title: isEditMode ? "Edit Purchase" : "Add Purchase",
          isEditMode: isEditMode,
          width: 0.5,
          height: double.infinity,
          content: SizedBox(
            height: 550,
            child: Column(
              children: [
                _buildFormHeader(),
                SizedBox(height: SizeConfig.sh(0.02)),
                _buildAddItemButton(),
                SizedBox(height: SizeConfig.sh(0.02)),
                _buildItemList(),
                SizedBox(height: SizeConfig.sh(0.02)),
                _buildTotalsCard(),
              ],
            ),
          ),
          onSave: () async {
            if (isEditMode) {
              await controller.updatePurchase(purchase);
            } else {
              await controller.addPurchase();
            }
          },
          onDelete: isEditMode
              ? () async {
                  await controller.deletePurchase(context, purchase.id ?? 0);
                  Get.back();
                }
              : null,
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ── Totals card ────────────────────────────────────────────────────────────
  Widget _buildTotalsCard() {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(
            vertical: SizeConfig.sh(0.005),
            horizontal: SizeConfig.sw(0.015),
          ),
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.sh(0.015),
            horizontal: SizeConfig.sw(0.015),
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: SizeConfig.sh(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _totalColumn(
                        label: 'Grand Total',
                        value: controller.grandTotal.toStringAsFixed(2),
                      ),
                      SizedBox(width: SizeConfig.sw(0.05)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discount Amount',
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2),
                                  color: _textMid)),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          SizedBox(
                            width: SizeConfig.sw(0.08), // अलि चौडा
                            height: SizeConfig.sh(0.06),
                            child: TextField(
                              controller: controller.discountAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.4),
                                  color: _textDark),
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (_) => controller.items.refresh(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),
                      _totalColumn(
                        label: 'Net Total',
                        value: controller.netTotal.toStringAsFixed(2),
                        valueColor: _primary,
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paid Amount',
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2),
                                  color: _textMid)),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          SizedBox(
                            width: SizeConfig.sw(0.1),
                            height: SizeConfig.sh(0.06),
                            child: TextField(
                              controller: controller.paidController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.4),
                                  color: _textDark),
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (_) => controller.items.refresh(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      _totalColumn(
                        label: 'Remaining',
                        value: controller.remaining.value.toStringAsFixed(2),
                        valueColor: controller.remaining.value > 0
                            ? _warning
                            : _success,
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status',
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2),
                                  color: _textMid)),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          _statusPill(controller.purchaseStatus.value),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _totalColumn(
      {required String label, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
        SizedBox(height: SizeConfig.sh(0.005)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: SizeConfig.res(4),
            color: valueColor ?? _textDark,
          ),
        ),
      ],
    );
  }

  // ── Item list ──────────────────────────────────────────────────────────────
  Widget _buildItemList() {
    return SizedBox(
      height: SizeConfig.sh(0.34),
      child: Obx(() => Scrollbar(
            controller: _itemScrollCtrl,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _itemScrollCtrl,
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final item = List.from(controller.items)[i];
                return Container(
                  margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.012),
                    vertical: SizeConfig.sh(0.01),
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: TextStyle(
                            fontSize: SizeConfig.res(3.4),
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.sw(0.05),
                        child: TextField(
                          controller: item.quantityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4), color: _textDark),
                          decoration: InputDecoration(
                            labelText: 'Qty',
                            labelStyle: TextStyle(
                                fontSize: SizeConfig.res(3), color: _textMid),
                          ),
                          onChanged: (_) => controller.items.refresh(),
                        ),
                      ),
                      SizedBox(width: SizeConfig.sw(0.01)),
                      SizedBox(
                        width: SizeConfig.sw(0.08),
                        child: TextField(
                          controller: item.priceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4), color: _textDark),
                          decoration: InputDecoration(
                            labelText: 'Price',
                            labelStyle: TextStyle(
                                fontSize: SizeConfig.res(3), color: _textMid),
                          ),
                          onChanged: (_) => controller.items.refresh(),
                        ),
                      ),
                      SizedBox(width: SizeConfig.sw(0.01)),
                      SizedBox(
                        width: SizeConfig.sw(0.09),
                        child: Obx(() => Text(
                              'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: SizeConfig.res(3.4),
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            )),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: _danger, size: SizeConfig.res(5)),
                        onPressed: () {
                          final itemToRemove = controller.items[i];
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => controller.items.remove(itemToRemove));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }

  // ── Form header ────────────────────────────────────────────────────────────
  Widget _buildFormHeader() {
    return Row(
      children: [
        SizedBox(
          width: SizeConfig.sw(0.15),
          child: TextField(
            controller: controller.dateController,
            readOnly: true,
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
            decoration: InputDecoration(
              labelText: 'Purchase Date',
              labelStyle:
                  TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
              suffixIcon: Icon(Icons.calendar_today_rounded,
                  size: SizeConfig.res(4.5), color: _primary),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _primary),
              ),
            ),
            onTap: () => controller.pickPurchaseDate(context),
          ),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Expanded(
          child: Obx(() {
            if (supplierController.suppliers.isEmpty) {
              supplierController.fetchSuppliers();
            }
            return DropdownButtonFormField<int>(
              value: controller.selectedSupplierId.value,
              items: supplierController.suppliers
                  .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => controller.selectedSupplierId.value = v,
              decoration: InputDecoration(
                labelText: 'Supplier',
                labelStyle:
                    TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primary),
                ),
              ),
            );
          }),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Expanded(
          child: Obx(() {
            if (staffController.staffs.isEmpty) {
              staffController.fetchStaff();
            }
            return DropdownButtonFormField<int>(
              value: controller.selectedStaffId.value,
              items: staffController.staffs
                  .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => controller.selectedStaffId.value = v,
              decoration: InputDecoration(
                labelText: 'Created By',
                labelStyle:
                    TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primary),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Add item button ────────────────────────────────────────────────────────
  Widget _buildAddItemButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          final searchCtrl = TextEditingController();

          StockModel? selected = await showDialog<StockModel>(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (_, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(
                  'Select Stock Item',
                  style: TextStyle(
                    fontSize: SizeConfig.res(4.5),
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                content: SizedBox(
                  width: SizeConfig.sw(0.4),
                  height: SizeConfig.sh(0.6),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: TextField(
                          controller: searchCtrl,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4), color: _textDark),
                          decoration: InputDecoration(
                            labelText: 'Search item',
                            prefixIcon: Icon(Icons.search,
                                color: _textMid, size: SizeConfig.res(5)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: SizeConfig.sh(0.015)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(height: SizeConfig.sh(0.012)),
                      Expanded(
                        child: Obx(() {
                          final filtered = stockController.stocks
                              .where((s) =>
                                  s.name.toLowerCase().contains(
                                      searchCtrl.text.toLowerCase()) ||
                                  s.itemNo
                                      .toLowerCase()
                                      .contains(searchCtrl.text.toLowerCase()))
                              .toList();
                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(
                                    color: _textMid,
                                    fontSize: SizeConfig.res(3.5)),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final s = filtered[index];
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: SizeConfig.sh(0.008)),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context, s),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(SizeConfig.res(3.5)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: SizeConfig.res(3.8),
                                                  color: _textDark,
                                                ),
                                              ),
                                              Text(
                                                'Item No: ${s.itemNo}',
                                                style: TextStyle(
                                                    fontSize: SizeConfig.res(3),
                                                    color: _textMid),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Stock: ${s.stock}',
                                            style: TextStyle(
                                              fontSize: SizeConfig.res(3.4),
                                              color: s.stock <= 0
                                                  ? _danger
                                                  : s.stock <= 5
                                                      ? _warning
                                                      : _success,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Buy: ${s.purchasePrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize:
                                                        SizeConfig.res(3.2),
                                                    color: _textDark),
                                              ),
                                              SizedBox(
                                                  height: SizeConfig.sh(0.004)),
                                              Text(
                                                'Sell: ${s.salePrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize:
                                                        SizeConfig.res(3.2),
                                                    color: _primary),
                                              ),
                                            ],
                                          ),
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
          if (selected != null) controller.addItem(selected);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.016),
            vertical: SizeConfig.sh(0.013),
          ),
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
              Text(
                'Add Item',
                style: TextStyle(
                  fontSize: SizeConfig.res(3.4),
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
