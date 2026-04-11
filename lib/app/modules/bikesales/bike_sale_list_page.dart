import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_detail_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class BikeSaleListPage extends StatefulWidget {
  const BikeSaleListPage({super.key});

  @override
  State<BikeSaleListPage> createState() => _BikeSaleListPageState();
}

class _BikeSaleListPageState extends State<BikeSaleListPage> {
  final BikeSaleController controller = Get.find();
  final GlobalController globalController = Get.find<GlobalController>();
  late final FollowUpController followUpController;

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
    {'label': 'All',     'value': 'all'},
    {'label': 'Paid',    'value': 'paid'},
    {'label': 'Pending', 'value': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    followUpController = Get.find<FollowUpController>();
    controller.fetchBikeSales(page: 1);
  }

  Future<void> _refresh() async => controller.fetchBikeSales(page: 1);

  List<BikeSale> _filteredSales() {
    final query = controller.searchText.value.toLowerCase();
    return controller.bikeSales.where((s) {
      if (controller.selectedStatus.value != 'all') {
        final pending = s.remainingAmount > 0;
        if (controller.selectedStatus.value == 'paid' && pending) return false;
        if (controller.selectedStatus.value == 'pending' && !pending) return false;
      }
      if (query.isNotEmpty &&
          !s.customerName.toLowerCase().contains(query) &&
          !s.vehicleModel.toLowerCase().contains(query) &&
          !s.registrationNo.toLowerCase().contains(query)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleDialog(),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Bike Sale',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600)),
        backgroundColor: _primary,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.res(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.sh(0.01)),
              _buildPageTitle(),
              SizedBox(height: SizeConfig.sh(0.018)),
              _buildHeader(),
              SizedBox(height: SizeConfig.sh(0.016)),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page title ─────────────────────────────────────────────────────────────
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bike Sales',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Manage vehicle sales and EMI records',
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
                      hintText: 'Search by name, model, reg no...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (v) => controller.searchText.value = v,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              Obx(() => _headerBtn(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    color: _primary,
                    onPressed: controller.isLoading.value ? null : _refresh,
                  )),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          Obx(() => Row(
                children: statuses.map((s) {
                  final isSelected = controller.selectedStatus.value == s['value'];
                  final color = s['value'] == 'paid' ? _success : s['value'] == 'pending' ? _warning : _primary;
                  return Padding(
                    padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
                    child: GestureDetector(
                      onTap: () => controller.selectedStatus.value = s['value']!,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.010)),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
                        ),
                        child: Text(s['label']!,
                            style: TextStyle(
                                fontSize: SizeConfig.res(3),
                                fontWeight: FontWeight.w600,
                                color: isSelected ? _surface : color)),
                      ),
                    ),
                  );
                }).toList(),
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
          color: onPressed == null ? _border.withOpacity(0.3) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onPressed == null ? _border : color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5), color: onPressed == null ? _textMid : color),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: onPressed == null ? _textMid : color)),
          ],
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
      final filtered = _filteredSales();
      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.two_wheeler, size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No bike sales found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _refresh,
        color: _primary,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _saleTile(filtered[i]),
        ),
      );
    });
  }

  // ── Sale tile ──────────────────────────────────────────────────────────────
  Widget _saleTile(BikeSale sale) {
    final isPending = sale.remainingAmount > 0;
    final statusColor = isPending ? _warning : _success;
    final isEmi = sale.isEmi || sale.saleType == SaleType.downpayment;

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      child: Slidable(
        key: ValueKey(sale.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => _openSaleDialog(sale: sale),
              backgroundColor: AppColors.warning,
              foregroundColor: _surface,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (_) => _deleteSale(sale.id),
              backgroundColor: _danger,
              foregroundColor: _surface,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Get.to(() => BikeSaleDetailPage(sale: sale)),
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
                // vehicle icon
                Container(
                  padding: EdgeInsets.all(SizeConfig.res(2.5)),
                  decoration: BoxDecoration(
                    color: _info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sale.vehicleType == VehicleType.bike
                        ? Icons.two_wheeler
                        : Icons.electric_scooter,
                    color: _info,
                    size: SizeConfig.res(6),
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
                                  color: _textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              if (isEmi) ...[
                                _badge('EMI', _primary),
                                SizedBox(width: SizeConfig.sw(0.006)),
                              ],
                              _statusPill(isPending ? 'PENDING' : 'PAID', statusColor),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      Row(
                        children: [
                          Icon(Icons.directions_bike_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(sale.vehicleModel,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2), color: _textMid)),
                          SizedBox(width: SizeConfig.sw(0.014)),
                          Icon(Icons.confirmation_number_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(sale.registrationNo,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2), color: _textMid)),
                          SizedBox(width: SizeConfig.sw(0.014)),
                          _badge(sale.paymentMethod.name.toUpperCase(), _primary),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.01)),
                      Row(
                        children: [
                          _amountChip('Total', sale.netTotal, _textDark),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip('Paid', sale.paidAmount, _success),
                          SizedBox(width: SizeConfig.sw(0.02)),
                          _amountChip('Remaining', sale.remainingAmount,
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

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.010), vertical: SizeConfig.sh(0.005)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3)),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w600,
              color: color)),
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

  // ── Delete ─────────────────────────────────────────────────────────────────
  void _deleteSale(int saleId) async {
    final success = await controller.deleteBikeSale(saleId);
    if (success) {
      followUpController.fetchFollowUps();
      globalController.triggerRefresh(DashboardRefreshType.all);
      Get.back(closeOverlays: true);
      DesktopToast.show('Sale deleted successfully', backgroundColor: _success);
    } else {
      DesktopToast.show('Failed to delete sale', backgroundColor: _danger);
    }
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
  void _openSaleDialog({BikeSale? sale}) {
    final isEdit = sale != null;
    controller.clearForm();
    if (isEdit) controller.fillForm(sale);

    Get.dialog(
      Obx(() => CustomFormDialog(
            title: isEdit ? 'Edit Bike Sale' : 'Add Bike Sale',
            width: 0.8,
            height: 0.85,
            isEditMode: isEdit,
            isSaving: controller.isLoading.value,
            onSave: () async {
              if (!controller.validateForm()) return;
              if (isEdit) {
                await controller.updateBikeSale(sale.id);
              } else {
                await controller.createBikeSale();
              }
            },
            onDelete: isEdit ? () => _deleteSale(sale.id) : null,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.sh(0.015)),
                  _formSection('Sale Date', Icons.calendar_today_rounded),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  SizedBox(
                    width: SizeConfig.sw(0.25),
                    child: CommonDatePicker(
                      label: 'Select Sale Date',
                      selectedDate: controller.saleDate,
                      firstDate: DateTime(2000),
                    ),
                  ),
                  SizedBox(height: SizeConfig.sh(0.025)),
                  _formSection('Customer Details', Icons.person_outline_rounded),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(width: SizeConfig.sw(0.25),
                          child: _field(controller.customerController, 'Customer Name', Icons.person)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.25),
                          child: _field(controller.vehicleModelController, 'Vehicle Model', Icons.directions_bike)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.contactController, 'Contact No', Icons.phone,
                              keyboardType: TextInputType.phone)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),
                  _formSection('Vehicle Details', Icons.two_wheeler),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.registrationController, 'Registration No', Icons.confirmation_number)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.chassisController, 'Chassis No', Icons.production_quantity_limits)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.engineController, 'Engine No', Icons.engineering)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.colorController, 'Color', Icons.color_lens)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.2),
                          child: _field(controller.kmDrivenController, 'KM Driven', Icons.speed,
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.025)),
                  _formSection('Payment Details', Icons.account_balance_wallet_outlined),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: Obx(() => _styledDropdown<SaleType>(
                              label: 'Sale Type',
                              value: controller.selectedSaleType.value,
                              items: SaleType.values
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e.name.toUpperCase())))
                                  .toList(),
                              onChanged: (v) => controller.selectedSaleType.value = v!,
                            )),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.15),
                          child: _field(controller.totalAmountController, 'Total Amount', Icons.money,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => controller.updateTotals())),
                      SizedBox(width: SizeConfig.sw(0.02)),
                     
                      SizedBox(width: SizeConfig.sw(0.15),
                          child: _field(controller.discountController, 'Discount Amount', Icons.money_off,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => controller.updateTotals())),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(width: SizeConfig.sw(0.15),
                          child: _field(controller.netTotalController, 'Net Total', Icons.attach_money,
                              enabled: false)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      Obx(() => SizedBox(
                            width: SizeConfig.sw(0.12),
                            child: _field(
                              controller.paidAmountController,
                              controller.selectedSaleType.value == SaleType.downpayment
                                  ? 'Total EMI Paid'
                                  : 'Paid Amount',
                              Icons.attach_money,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => controller.updateTotals(),
                            ),
                          )),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(width: SizeConfig.sw(0.12),
                          child: _field(controller.remainingController, 'Remaining', Icons.money_off,
                              enabled: false)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      Obx(() {
                        if (controller.selectedSaleType.value != SaleType.downpayment) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          width: SizeConfig.sw(0.12),
                          child: _field(controller.initialPaidController, 'Down Payment', Icons.payment,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => controller.updateTotals()),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Obx(() {
                    final showEmi = controller.selectedSaleType.value == SaleType.emi ||
                        controller.selectedSaleType.value == SaleType.downpayment;
                    if (!showEmi) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: SizeConfig.sh(0.01)),
                        _formSection('EMI Details', Icons.timer_outlined),
                        SizedBox(height: SizeConfig.sh(0.01)),
                        Row(
                          children: [
                            SizedBox(width: SizeConfig.sw(0.2),
                                child: _field(controller.emiTenureController, 'EMI Tenure (Months)', Icons.timer,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => controller.updateTotals())),
                            SizedBox(width: SizeConfig.sw(0.02)),
                            SizedBox(width: SizeConfig.sw(0.2),
                                child: _field(controller.emiAmountController, 'EMI Amount', Icons.attach_money,
                                    enabled: false)),
                          ],
                        ),
                        SizedBox(height: SizeConfig.sh(0.01)),
                      ],
                    );
                  }),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  SizedBox(
                    width: SizeConfig.sw(0.25),
                    child: Obx(() => _styledDropdown<PaymentMethod>(
                          label: 'Payment Method',
                          value: controller.selectedPaymentMethod.value,
                          items: PaymentMethod.values
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e.name.toUpperCase())))
                              .toList(),
                          onChanged: (v) => controller.selectedPaymentMethod.value = v!,
                        )),
                  ),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  _field(controller.remarksController, 'Remarks', Icons.note_outlined),
                  SizedBox(height: SizeConfig.sh(0.02)),
                ],
              ),
            ),
          )),
      barrierDismissible: false,
    );
  }

  // ── Form widgets ───────────────────────────────────────────────────────────
  Widget _formSection(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2)),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4), color: _primary),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Text(title,
            style: TextStyle(
                fontSize: SizeConfig.res(4),
                fontWeight: FontWeight.w700,
                color: _textDark)),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
          fontSize: SizeConfig.res(3.4),
          color: enabled ? _textDark : _textMid),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        prefixIcon: Icon(icon, size: SizeConfig.res(4.5),
            color: enabled ? _primary : _textMid),
        filled: !enabled,
        fillColor: enabled ? null : _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border.withOpacity(0.5)),
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
}