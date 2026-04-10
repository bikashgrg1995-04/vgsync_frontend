import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_detail_page.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  final SalesController controller = Get.find();
  final StaffController staffController = Get.find();
  final StockController stockController = Get.find();
  final GlobalController globalController = Get.find();

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

  final statuses = const [
    {'label': 'All',      'value': 'all'},
    {'label': 'Paid',     'value': 'paid'},
    {'label': 'Partial',  'value': 'partial'},
    {'label': 'Not Paid', 'value': 'not_paid'},
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchSales();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':    return _success;
      case 'partial': return _warning;
      default:        return _danger;
    }
  }

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
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.016)),
            Expanded(child: _buildSaleList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleDialog(context),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text(
          'Add Sale',
          style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600),
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
          'Sales',
          style: TextStyle(
            fontSize: SizeConfig.res(7),
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Manage and track all sale records',
          style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid),
        ),
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
                      hintText: 'Search sales...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (v) => controller.searchText.value = v,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              Obx(() => _headerButton(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onPressed: controller.isLoading.value ? null : () async => await controller.refreshSales(),
                    color: _primary,
                  )),
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
    required VoidCallback? onPressed,
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
          color: onPressed == null ? _border.withOpacity(0.3) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onPressed == null ? _border : color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5), color: onPressed == null ? _textMid : color),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.res(3.2),
                fontWeight: FontWeight.w600,
                color: onPressed == null ? _textMid : color,
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
                Icon(Icons.calendar_today_rounded, size: SizeConfig.res(4), color: _primary),
                SizedBox(width: SizeConfig.sw(0.006)),
                Text(
                  controller.filterSelectedDate.value == null
                      ? 'Select Date'
                      : controller.filterSelectedDate.value!.toIso8601String().split('T')[0],
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
                    child: Icon(Icons.close_rounded, size: SizeConfig.res(3.5), color: _primary),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildStatusFilter() {
    return Obx(() => Row(
          children: statuses.map((s) {
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
                    border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
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

  // ── Sale list ──────────────────────────────────────────────────────────────
  List<SaleModel> _filteredSales() {
    final query = controller.searchText.value.toLowerCase();
    return controller.sales.where((sale) {
      if (controller.selectedStatus.value != 'all' &&
          sale.isPaid != controller.selectedStatus.value) return false;
      if (controller.filterSelectedDate.value != null) {
        final d = controller.filterSelectedDate.value!;
        if (sale.saleDate.year != d.year ||
            sale.saleDate.month != d.month ||
            sale.saleDate.day != d.day) return false;
      }
      if (query.isNotEmpty && !sale.customerName.toLowerCase().contains(query)) return false;
      return true;
    }).toList();
  }

  Widget _buildSaleList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      final list = _filteredSales();
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No sales found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: list.length,
        itemBuilder: (_, i) => _saleTile(list[i]),
      );
    });
  }

  Widget _saleTile(SaleModel sale) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      child: Slidable(
        key: ValueKey(sale.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => _openSaleDialog(context, sale: sale),
              backgroundColor: AppColors.warning,
              foregroundColor: _surface,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (_) => controller.deleteSale(context, sale.id ?? 0),
              backgroundColor: _danger,
              foregroundColor: _surface,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.to(() => SaleDetailPage(sale: sale)),
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
                // status accent bar
                Container(
                  width: SizeConfig.sw(0.006),
                  height: SizeConfig.sh(0.09),
                  decoration: BoxDecoration(
                    color: _statusColor(sale.isPaid),
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
                            child: Text(
                              sale.customerName.capitalizeFirst ?? '',
                              style: TextStyle(
                                fontSize: SizeConfig.res(4),
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _statusPill(sale.isPaid),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(
                            sale.saleDate.toIso8601String().split('T')[0],
                            style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                          ),
                          if (sale.billNo != null) ...[
                            SizedBox(width: SizeConfig.sw(0.016)),
                            Icon(Icons.receipt_outlined,
                                size: SizeConfig.res(3.2), color: _textMid),
                            SizedBox(width: SizeConfig.sw(0.004)),
                            Text(
                              'Bill #${sale.billNo}',
                              style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                            ),
                          ],
                          if (sale.isServicing) ...[
                            SizedBox(width: SizeConfig.sw(0.016)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.sw(0.008),
                                  vertical: SizeConfig.sh(0.003)),
                              decoration: BoxDecoration(
                                color: _info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.build_outlined,
                                      size: SizeConfig.res(3), color: _info),
                                  SizedBox(width: SizeConfig.sw(0.003)),
                                  Text('Servicing',
                                      style: TextStyle(
                                          fontSize: SizeConfig.res(2.8),
                                          color: _info,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.01)),
                      Row(
                        children: [
                          _amountChip(label: 'Total', value: sale.netTotal, color: _textDark),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip(label: 'Paid', value: sale.paidAmount, color: _success),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip(
                            label: 'Remaining',
                            value: sale.remainingAmount,
                            color: sale.remainingAmount > 0 ? _warning : _success,
                          ),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _paidFromBadge(sale.paidFrom),
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

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.010), vertical: SizeConfig.sh(0.005)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: SizeConfig.res(2.8),
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _amountChip({required String label, required double value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.res(2.6), color: _textMid)),
        Text(
          'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(fontSize: SizeConfig.res(3.4), fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _paidFromBadge(String paidFrom) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Text(
        paidFrom.toUpperCase(),
        style: TextStyle(
          fontSize: SizeConfig.res(2.8),
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
      ),
    );
  }

  // ── Dialog helpers (same style as before) ─────────────────────────────────
  void _openSaleDialog(BuildContext context, {SaleModel? sale}) {
    final isEdit = sale != null;
    controller.clearForm();
    if (isEdit) controller.fillForEdit(sale);
    controller.isServicing.value = sale?.isServicing ?? false;

    final staffSelected = (sale?.handledBy ?? 0).obs;
    const paidFromOptions = ['cash', 'online', 'bank'];
    final initialPaidFrom =
        (sale?.paidFrom != null && paidFromOptions.contains(sale!.paidFrom))
            ? sale.paidFrom
            : 'cash';
    final paidFrom = initialPaidFrom.obs;

    controller.discountAmountController.text = (sale?.discountAmount ?? 0).toStringAsFixed(2);
    controller.updateTotals();

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Sale' : 'Add Sale',
        isEditMode: isEdit,
        width: 0.6,
        height: 0.9,
        content: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.sh(0.02)),
              Row(
                children: [
                  SizedBox(width: SizeConfig.sw(0.1),
                      child: _styledField('Bill No', controller.billNoController)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(width: SizeConfig.sw(0.2),
                      child: _styledField('Customer Name', controller.customerNameController)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(width: SizeConfig.sw(0.15),
                      child: _styledField('Contact No', controller.contactNoController)),
                ],
              ),
              SizedBox(height: SizeConfig.sh(0.02)),
              Row(
                children: [
                  SizedBox(width: SizeConfig.sw(0.1),
                      child: _styledDatePicker('Sale Date', controller.saleDate, required: true)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: Obx(() {
                      if (staffController.staffs.isEmpty) return const SizedBox();
                      if (staffSelected.value == 0) {
                        staffSelected.value = staffController.staffs.first.id!;
                      }
                      return _styledDropdown<int>(
                        label: 'Staff',
                        value: staffSelected.value,
                        items: staffController.staffs
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => staffSelected.value = v ?? 0,
                      );
                    }),
                  ),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: Obx(() => _servicingSwitch()),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.sh(0.02)),
              Obx(() {
                if (!controller.isServicing.value) return const SizedBox();
                return _servicingSection();
              }),
              SizedBox(height: SizeConfig.sh(0.02)),
              _itemsContainer(),
              SizedBox(height: SizeConfig.sh(0.02)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.4),
                    child: _styledField('Remarks', controller.remarksController),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selectedStock = await _selectStock(context);
                      if (selectedStock != null) {
                        controller.addItem(SaleItemModel.fromStock(selectedStock));
                        controller.updateTotals();
                      }
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
                          Text('Add Item',
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.4),
                                  fontWeight: FontWeight.w600,
                                  color: _primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.sh(0.02)),
              _buildSaleTotalsCard(paidFrom),
            ],
          ),
        ),
        onSave: () async {
          if (!controller.validateForm()) return;
          controller.paidFrom.value = paidFrom.value;
          controller.updateTotals();
          if (isEdit) {
            final success = await controller.updateSale(sale.id!);
            if (!success) return;
            controller.clearForm();
            Get.back(closeOverlays: true);
            DesktopToast.show('Sale updated successfully',
                backgroundColor: _success);
          } else {
            final success = await controller.addSale();
            if (!success) return;
            controller.clearForm();
            Get.back(closeOverlays: true);
            DesktopToast.show('Sale added successfully',
                backgroundColor: _success);
          }
        },
        onDelete: isEdit
            ? () async => await controller.deleteSale(context, sale.id!)
            : null,
      ),
      barrierDismissible: false,
    );
  }

  // ── Styled form widgets ────────────────────────────────────────────────────
  Widget _styledField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text,
      void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border),
        ),
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
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border),
        ),
      ),
    );
  }

  Widget _styledDatePicker(String label, Rx<DateTime?> dateField,
      {bool required = false}) {
    return Obx(() => GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dateField.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: _primary)),
                child: child!,
              ),
            );
            if (picked != null) {
              dateField.value = picked;
              if (dateField == controller.deliveryDate) {
                controller.updateDerivedDates();
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.018)),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: required && dateField.value == null
                    ? _danger
                    : _border,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: SizeConfig.res(4), color: _primary),
                SizedBox(width: SizeConfig.sw(0.008)),
                Expanded(
                  child: Text(
                    dateField.value == null
                        ? '$label${required ? ' *' : ''}'
                        : dateField.value!.toIso8601String().split('T').first,
                    style: TextStyle(
                      fontSize: SizeConfig.res(3.2),
                      color: dateField.value == null ? _textMid : _textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _readonlyDateWidget(String label, Rx<DateTime?> dateField) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.018)),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: SizeConfig.res(4), color: _textMid),
              SizedBox(width: SizeConfig.sw(0.008)),
              Expanded(
                child: Text(
                  dateField.value == null
                      ? label
                      : dateField.value!.toIso8601String().split('T').first,
                  style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _servicingSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: controller.isServicing.value
            ? _info.withOpacity(0.08)
            : _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: controller.isServicing.value
              ? _info.withOpacity(0.3)
              : _border,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'Servicing',
          style: TextStyle(
              fontSize: SizeConfig.res(3.2),
              color: controller.isServicing.value ? _info : _textMid,
              fontWeight: FontWeight.w600),
        ),
        value: controller.isServicing.value,
        activeColor: _info,
        onChanged: (v) => controller.isServicing.value = v,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.008)),
      ),
    );
  }

  Widget _servicingSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.015)),
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _info.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.res(2)),
                decoration: BoxDecoration(
                    color: _info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.build_rounded, color: _info, size: SizeConfig.res(4.5)),
              ),
              SizedBox(width: SizeConfig.sw(0.01)),
              Text('Servicing Details',
                  style: TextStyle(
                      fontSize: SizeConfig.res(4),
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Vehicle Information'),
          _twoCol(
            _styledField('Vehicle Model', controller.vehicleModelController),
            _styledField('Vehicle Color', controller.vehicleColorController),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _twoCol(
            _styledField('KM Driven', controller.kmDrivenController,
                keyboardType: TextInputType.number),
            _styledField('Bike Reg. No', controller.bikeRegistrationController),
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Job Details'),
          _twoCol(
            _styledField('Job Card No', controller.jobCardNoController),
            _styledField('Technician', controller.technicianNameController),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _styledField('Job Done On Vehicle', controller.jobDoneOnVehicleController),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Charges & Dates'),
          _twoCol(
            _styledField('Labour Charge', controller.labourChargeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.updateTotals()),
            _styledDatePicker('Received Date', controller.receivedDate),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _twoCol(
            _styledDatePicker('Delivery Date', controller.deliveryDate, required: true),
            _readonlyDateWidget('Follow Up Date', controller.followUpDate),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _readonlyDateWidget('Post Service Feedback Date', controller.postServiceFeedbackDate),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Service Type'),
          Wrap(
            spacing: SizeConfig.sw(0.01),
            runSpacing: SizeConfig.sh(0.006),
            children: [
              _serviceChip('Free Servicing', controller.isFreeServicing),
              _serviceChip('Repair Job', controller.isRepairJob),
              _serviceChip('Accident Case', controller.isAccident),
              _serviceChip('Warranty Job', controller.isWarrantyJob),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
      child: Text(text,
          style: TextStyle(
              fontSize: SizeConfig.res(3.2),
              fontWeight: FontWeight.w600,
              color: _textMid,
              letterSpacing: 0.2)),
    );
  }

  Widget _twoCol(Widget left, Widget right) {
    return Row(children: [
      Expanded(child: left),
      SizedBox(width: SizeConfig.sw(0.012)),
      Expanded(child: right),
    ]);
  }

  Widget _serviceChip(String title, RxBool value) {
    return Obx(() => GestureDetector(
          onTap: () => value.value = !value.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.009)),
            decoration: BoxDecoration(
              color: value.value ? _info.withOpacity(0.1) : _bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: value.value ? _info.withOpacity(0.4) : _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.value)
                  Padding(
                    padding: EdgeInsets.only(right: SizeConfig.sw(0.004)),
                    child: Icon(Icons.check_circle_rounded,
                        size: SizeConfig.res(3.5), color: _info),
                  ),
                Text(title,
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.2),
                        color: value.value ? _info : _textMid,
                        fontWeight: value.value ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ));
  }

  Widget _itemsContainer() {
    return Container(
      height: SizeConfig.sh(0.3),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Obx(() {
        if (controller.selectedItems.isEmpty) {
          return Center(
            child: Text('No items added yet',
                style: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4))),
          );
        }
        return ListView(
          padding: EdgeInsets.all(SizeConfig.res(2)),
          children: controller.selectedItems.map((c) => _itemRow(c)).toList(),
        );
      }),
    );
  }

  Widget _itemRow(SaleItemController ctrl) {
    final item = ctrl.item;
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.008)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.itemName,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
          ),
          SizedBox(
            width: SizeConfig.sw(0.07),
            child: TextField(
              controller: ctrl.quantityController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
              decoration: InputDecoration(
                labelText: 'Qty',
                labelStyle: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border),
                ),
              ),
              onChanged: (_) => ctrl.parentController.updateTotals(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(
            width: SizeConfig.sw(0.09),
            child: TextField(
              controller: ctrl.priceController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
              decoration: InputDecoration(
                labelText: 'Rate',
                labelStyle: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border),
                ),
              ),
              onChanged: (_) => ctrl.parentController.updateTotals(),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          Obx(() => SizedBox(
                width: SizeConfig.sw(0.09),
                child: Text(
                  'Rs. ${ctrl.totalPrice.value.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.2),
                      fontWeight: FontWeight.w700,
                      color: _primary),
                ),
              )),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                size: SizeConfig.res(4.5), color: _danger),
            onPressed: () => ctrl.parentController.removeItem(ctrl),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleTotalsCard(RxString paidFrom) {
    const paidFromOptions = ['cash', 'online', 'bank'];
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.008)),
          padding: EdgeInsets.all(SizeConfig.res(4)),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _totalCol('Grand Total', controller.totalAmount.toStringAsFixed(2), _textDark),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount Amount',
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      SizedBox(
                        width: SizeConfig.sw(0.05),
                        height: SizeConfig.sh(0.055),
                        child: TextField(
                          controller: controller.discountAmountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _primary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: _border),
                            ),
                          ),
                          onChanged: (_) => controller.updateTotals(),
                        ),
                      ),
                     
                    ],
                  ),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  _totalCol('Net Total', controller.netAmount.toStringAsFixed(2), _primary,
                      isBold: true),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paid Amount',
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      SizedBox(
                        width: SizeConfig.sw(0.1),
                        height: SizeConfig.sh(0.055),
                        child: TextField(
                          controller: controller.paidAmountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _success, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: _border),
                            ),
                          ),
                          onChanged: (_) => controller.updateTotals(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.sh(0.016)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _totalCol(
                    'Remaining',
                    controller.remainingAmount.toStringAsFixed(2),
                    controller.remainingAmount > 0 ? _warning : _success,
                    isBold: true,
                  ),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paid From',
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      SizedBox(
                        width: SizeConfig.sw(0.1),
                        child: DropdownButtonFormField<String>(
                          value: paidFromOptions.contains(paidFrom.value) ? paidFrom.value : null,
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
                          items: paidFromOptions
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                              .toList(),
                          onChanged: (v) {
                            paidFrom.value = v ?? 'cash';
                            controller.paidFrom.value = v ?? 'cash';
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.sw(0.008),
                                vertical: SizeConfig.sh(0.012)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _primary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: _border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status',
                          style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      _statusPill(controller.saleStatus.value),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _totalCol(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
        SizedBox(height: SizeConfig.sh(0.004)),
        Text(value,
            style: TextStyle(
                fontSize: SizeConfig.res(isBold ? 4 : 3.6),
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color)),
      ],
    );
  }

  Future<dynamic> _selectStock(BuildContext context) async {
    final searchCtrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Stock Item',
              style: TextStyle(
                  fontSize: SizeConfig.res(4.5),
                  fontWeight: FontWeight.w700,
                  color: _textDark)),
          content: SizedBox(
            width: SizeConfig.sw(0.4),
            height: SizeConfig.sh(0.6),
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
                      hintText: 'Search item...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      prefixIcon:
                          Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(height: SizeConfig.sh(0.012)),
                Expanded(
                  child: Obx(() {
                    final filtered = stockController.stocks
                        .where((s) =>
                            s.name.toLowerCase().contains(searchCtrl.text.toLowerCase()) ||
                            s.itemNo.toLowerCase().contains(searchCtrl.text.toLowerCase()))
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(
                          child: Text('No items found',
                              style: TextStyle(
                                  color: _textMid, fontSize: SizeConfig.res(3.5))));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final s = filtered[index];
                        final isOut = s.stock <= 0;
                        final isAlready = controller.selectedItems
                            .any((item) => item.item.itemId == s.id);
                        final isDisabled = isOut || isAlready;
                        final stockColor = isOut
                            ? _danger
                            : s.stock <= 5
                                ? _warning
                                : _success;
                        return Container(
                          margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
                          decoration: BoxDecoration(
                            color: isOut
                                ? _danger.withOpacity(0.04)
                                : isAlready
                                    ? _warning.withOpacity(0.04)
                                    : _bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOut
                                  ? _danger.withOpacity(0.3)
                                  : isAlready
                                      ? _warning.withOpacity(0.3)
                                      : _border,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (isOut) {
                                DesktopToast.show('Item is out of stock',
                                    backgroundColor: _danger);
                                return;
                              }
                              if (isAlready) {
                                DesktopToast.show(
                                    'Item already selected. Edit from above list.',
                                    backgroundColor: _warning);
                                return;
                              }
                              Navigator.pop(context, s);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.res(3.5)),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: SizeConfig.res(3.6),
                                                color: isDisabled ? _textMid : _textDark)),
                                        Text('No: ${s.itemNo}',
                                            style: TextStyle(
                                                fontSize: SizeConfig.res(3), color: _textMid)),
                                        if (isOut)
                                          Text('Out of Stock',
                                              style: TextStyle(
                                                  fontSize: SizeConfig.res(3),
                                                  color: _danger,
                                                  fontWeight: FontWeight.w600)),
                                        if (isAlready)
                                          Text('Already selected',
                                              style: TextStyle(
                                                  fontSize: SizeConfig.res(3),
                                                  color: _warning,
                                                  fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.sw(0.008),
                                        vertical: SizeConfig.sh(0.005)),
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
                                  SizedBox(width: SizeConfig.sw(0.012)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Buy: Rs.${s.purchasePrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: SizeConfig.res(3.2),
                                              fontWeight: FontWeight.w600,
                                              color: _textDark)),
                                      Text('Sell: Rs.${s.salePrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: SizeConfig.res(3), color: _primary)),
                                    ],
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
  }
}