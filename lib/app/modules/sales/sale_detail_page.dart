import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

class SaleDetailPage extends StatelessWidget {
  final SaleModel sale;

  SaleDetailPage({super.key, required this.sale});

  final SalesController controller = Get.find();
  final StaffController staffController = Get.find<StaffController>();
  final StockController stockController = Get.find<StockController>();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const _bg = AppColors.background;
  static const _surface = AppColors.surface;
  static const _primary = AppColors.primary;
  static const _success = AppColors.success;
  static const _warning = AppColors.warning;
  static const _danger = AppColors.error;
  static const _info = AppColors.info;
  static const _textDark = AppColors.textPrimary;
  static const _textMid = AppColors.textSecondary;
  static const _border = AppColors.divider;
  static const _shadow = Color(0x0F000000);

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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoStrip(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _summaryCard(),
            SizedBox(height: SizeConfig.sh(0.018)),
            if (sale.isServicing) ...[
              _servicingCard(),
              SizedBox(height: SizeConfig.sh(0.018)),
            ],
            _itemsCard(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _totalsCard(),
            SizedBox(height: SizeConfig.sh(0.03)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.all(SizeConfig.res(2.5)),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(Icons.arrow_back_rounded,
              color: _textDark, size: SizeConfig.res(5)),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sale Details',
              style: TextStyle(
                  fontSize: SizeConfig.res(4.8),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.3)),
          Text('Bill #${sale.billNo ?? sale.id ?? "-"}',
              style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
          child: GestureDetector(
            onTap: () => _openSaleDialog(context, sale: sale),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.014),
                  vertical: SizeConfig.sh(0.010)),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded,
                      size: SizeConfig.res(4), color: _primary),
                  SizedBox(width: SizeConfig.sw(0.005)),
                  Text('Edit',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.4),
                          fontWeight: FontWeight.w600,
                          color: _primary)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.sw(0.012)),
          child: GestureDetector(
            onTap: () => controller.deleteSale(context, sale.id!),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.014),
                  vertical: SizeConfig.sh(0.010)),
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _danger.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: SizeConfig.res(4), color: _danger),
                  SizedBox(width: SizeConfig.sw(0.005)),
                  Text('Delete',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.4),
                          fontWeight: FontWeight.w600,
                          color: _danger)),
                ],
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ── Info strip ─────────────────────────────────────────────────────────────
  Widget _infoStrip() {
    final status = sale.isPaid;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.014)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: SizeConfig.sw(0.006),
            height: SizeConfig.sh(0.06),
            decoration: BoxDecoration(
              color: _statusColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.014)),
          Expanded(
            child: Row(
              children: [
                _infoTile(Icons.tag_rounded, 'Order', '#${sale.id ?? "-"}'),
                _vDivider(),
                _infoTile(Icons.calendar_today_rounded, 'Date',
                    sale.saleDate.toIso8601String().split('T')[0]),
                _vDivider(),
                _infoTile(Icons.person_outline_rounded, 'Customer',
                    sale.customerName.capitalizeFirst ?? ''),
                _vDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: TextStyle(
                            fontSize: SizeConfig.res(2.8), color: _textMid)),
                    SizedBox(height: SizeConfig.sh(0.004)),
                    _statusPill(status),
                  ],
                ),
                if (sale.isServicing) ...[
                  _vDivider(),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.006)),
                    decoration: BoxDecoration(
                      color: _info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _info.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.build_outlined,
                            size: SizeConfig.res(3.5), color: _info),
                        SizedBox(width: SizeConfig.sw(0.005)),
                        Text('Servicing',
                            style: TextStyle(
                                fontSize: SizeConfig.res(3),
                                fontWeight: FontWeight.w600,
                                color: _info)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2)),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: SizeConfig.res(4), color: _primary),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: SizeConfig.res(2.8), color: _textMid)),
              Text(value,
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4),
                      fontWeight: FontWeight.w700,
                      color: _textDark),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: SizeConfig.sh(0.05),
      color: _border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
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
            letterSpacing: 0.3),
      ),
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────
  Widget _summaryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.info_outline_rounded, 'Sale Information'),
          SizedBox(height: SizeConfig.sh(0.016)),
          _infoGrid([
            _InfoItem('Date', sale.saleDate.toIso8601String().split('T')[0]),
            _InfoItem('Bill No', sale.billNo ?? '-'),
            _InfoItem('Customer', sale.customerName.capitalizeFirst ?? ''),
            _InfoItem('Contact', sale.contactNo.toString()),
            _InfoItem('Paid From', sale.paidFrom.toUpperCase()),
            _InfoItem('Remarks', sale.remarks ?? '-'),
          ]),
        ],
      ),
    );
  }

  // ── Items card ─────────────────────────────────────────────────────────────
  Widget _itemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.inventory_2_outlined, 'Items'),
          SizedBox(height: SizeConfig.sh(0.014)),
          // Table header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.012),
                vertical: SizeConfig.sh(0.01)),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.03),
                  child: Text('#',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ),
                SizedBox(width: SizeConfig.sw(0.008)),
                Expanded(
                  child: Text('Item',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ),
                SizedBox(
                  width: SizeConfig.sw(0.08),
                  child: Text('Qty × Rate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ),
                SizedBox(
                  width: SizeConfig.sw(0.09),
                  child: Text('Total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.sh(0.008)),
          ...sale.items.asMap().entries.map((e) {
            final idx = e.key;
            final i = e.value;
            final isEven = idx.isEven;
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.012),
                  vertical: SizeConfig.sh(0.012)),
              decoration: BoxDecoration(
                color: isEven ? _bg : _surface,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border(bottom: BorderSide(color: _border.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.03),
                    child: Text('${idx + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.2), color: _textMid)),
                  ),
                  SizedBox(width: SizeConfig.sw(0.008)),
                  Expanded(
                    child: Text(i.itemName,
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.4),
                            fontWeight: FontWeight.w600,
                            color: _textDark)),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.08),
                    child: Text(
                      '${i.quantity} × ${i.salePrice.toStringAsFixed(0)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.2), color: _textMid),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.09),
                    child: Text(
                      'Rs. ${(i.quantity * i.salePrice).toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.4),
                          fontWeight: FontWeight.w700,
                          color: _primary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Servicing card ─────────────────────────────────────────────────────────
  Widget _servicingCard() {
    return _card(
      borderColor: _info.withOpacity(0.3),
      bgColor: _info.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.build_rounded, 'Servicing Details', color: _info),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Vehicle Information'),
          SizedBox(height: SizeConfig.sh(0.008)),
          _infoGrid([
            _InfoItem('Vehicle Model', sale.vehicleModel ?? '-'),
            _InfoItem('Vehicle Color', sale.vehicleColor ?? '-'),
            _InfoItem('KM Driven', sale.kmDriven?.toString() ?? '-'),
            _InfoItem('Bike Reg. No', sale.bikeRegistrationNo ?? '-'),
          ]),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Job Details'),
          SizedBox(height: SizeConfig.sh(0.008)),
          _infoGrid([
            _InfoItem('Job Card No', sale.jobCardNo ?? '-'),
            _InfoItem('Technician', sale.technicianName ?? '-'),
            _InfoItem(
                'Labour Charge', 'Rs. ${sale.labourCharge.toStringAsFixed(0)}'),
            _InfoItem('Job Done', sale.jobDoneOnVehicle ?? '-'),
          ]),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Dates'),
          SizedBox(height: SizeConfig.sh(0.008)),
          _infoGrid([
            _InfoItem('Received',
                sale.receivedDate?.toIso8601String().split('T')[0] ?? '-'),
            _InfoItem('Delivery',
                sale.deliveryDate?.toIso8601String().split('T')[0] ?? '-'),
            _InfoItem('Follow Up',
                sale.followUpDate?.toIso8601String().split('T')[0] ?? '-'),
            _InfoItem(
                'Post Feedback',
                sale.postServiceFeedbackDate?.toIso8601String().split('T')[0] ??
                    '-'),
          ]),
          if (_hasServiceFlags()) ...[
            SizedBox(height: SizeConfig.sh(0.016)),
            _sectionLabel('Service Type'),
            SizedBox(height: SizeConfig.sh(0.008)),
            Wrap(
              spacing: SizeConfig.sw(0.01),
              runSpacing: SizeConfig.sh(0.006),
              children: [
                if (sale.isFreeServicing)
                  _flagBadge('Free Servicing', _success),
                if (sale.isRepairJob) _flagBadge('Repair Job', _warning),
                if (sale.isAccident) _flagBadge('Accident Case', _danger),
                if (sale.isWarrantyJob) _flagBadge('Warranty Job', _info),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _hasServiceFlags() =>
      sale.isFreeServicing ||
      sale.isRepairJob ||
      sale.isAccident ||
      sale.isWarrantyJob;

  Widget _flagBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.006)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              size: SizeConfig.res(3.5), color: color),
          SizedBox(width: SizeConfig.sw(0.005)),
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.res(3.2),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Totals card ────────────────────────────────────────────────────────────
  Widget _totalsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.receipt_outlined, 'Payment Summary'),
          SizedBox(height: SizeConfig.sh(0.016)),
          Row(
            children: [
              _totalTile(Icons.account_balance_wallet_outlined, 'Grand Total',
                  sale.grandTotal, _textDark),
              _vDivider(),
              _totalTile(
                  Icons.local_offer_outlined,
                  'Discount (${sale.discountPercentage}%)',
                  sale.grandTotal - sale.netTotal,
                  _warning),
              _vDivider(),
              _totalTile(
                  Icons.receipt_outlined, 'Net Total', sale.netTotal, _primary,
                  isBold: true),
              _vDivider(),
              _totalTile(Icons.check_circle_outline, 'Paid', sale.paidAmount,
                  _success),
              _vDivider(),
              _totalTile(
                  Icons.pending_outlined,
                  'Remaining',
                  sale.remainingAmount,
                  sale.remainingAmount > 0 ? _danger : _success,
                  isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalTile(IconData icon, String label, double value, Color color,
      {bool isBold = false}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2.2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: SizeConfig.res(4.5), color: color),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: SizeConfig.res(2.8), color: _textMid)),
                SizedBox(height: SizeConfig.sh(0.003)),
                Text('Rs. ${value.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: SizeConfig.res(isBold ? 4 : 3.6),
                        fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                        color: color),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _card({required Widget child, Color? borderColor, Color? bgColor}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: bgColor ?? _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title, {Color? color}) {
    final c = color ?? _primary;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2.2)),
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4.5), color: c),
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

  Widget _sectionLabel(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: SizeConfig.res(3.2),
            fontWeight: FontWeight.w600,
            color: _textMid,
            letterSpacing: 0.2));
  }

  Widget _infoGrid(List<_InfoItem> items) {
    return Wrap(
      spacing: SizeConfig.sw(0.04),
      runSpacing: SizeConfig.sh(0.012),
      children: items
          .map((item) => SizedBox(
                width: SizeConfig.sw(0.18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: TextStyle(
                            fontSize: SizeConfig.res(2.8), color: _textMid)),
                    SizedBox(height: SizeConfig.sh(0.003)),
                    Text(item.value,
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.4),
                            fontWeight: FontWeight.w600,
                            color: _textDark),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ))
          .toList(),
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

    controller.discountController.text =
        (sale?.discountPercentage ?? 0).toString();
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
                  SizedBox(
                      width: SizeConfig.sw(0.1),
                      child:
                          _styledField('Bill No', controller.billNoController)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(
                      width: SizeConfig.sw(0.2),
                      child: _styledField(
                          'Customer Name', controller.customerNameController)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(
                      width: SizeConfig.sw(0.15),
                      child: _styledField(
                          'Contact No', controller.contactNoController)),
                ],
              ),
              SizedBox(height: SizeConfig.sh(0.02)),
              Row(
                children: [
                  SizedBox(
                      width: SizeConfig.sw(0.1),
                      child: _styledDatePicker(context, 'Sale Date', controller.saleDate,
                          required: true)),
                  SizedBox(width: SizeConfig.sw(0.02)),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: Obx(() {
                      if (staffController.staffs.isEmpty)
                        return const SizedBox();
                      if (staffSelected.value == 0) {
                        staffSelected.value = staffController.staffs.first.id!;
                      }
                      return _styledDropdown<int>(
                        label: 'Staff',
                        value: staffSelected.value,
                        items: staffController.staffs
                            .map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.name)))
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
                return _servicingSection(context);
              }),
              SizedBox(height: SizeConfig.sh(0.02)),
              _itemsContainer(),
              SizedBox(height: SizeConfig.sh(0.02)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.4),
                    child:
                        _styledField('Remarks', controller.remarksController),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selectedStock = await _selectStock(context);
                      if (selectedStock != null) {
                        controller
                            .addItem(SaleItemModel.fromStock(selectedStock));
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

  Widget _styledDatePicker(BuildContext context,String label, Rx<DateTime?> dateField,
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
                horizontal: SizeConfig.sw(0.012),
                vertical: SizeConfig.sh(0.018)),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: required && dateField.value == null ? _danger : _border,
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
                  style:
                      TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _servicingSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: controller.isServicing.value ? _info.withOpacity(0.08) : _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              controller.isServicing.value ? _info.withOpacity(0.3) : _border,
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

  Widget _servicingSection(BuildContext context) {
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
                child: Icon(Icons.build_rounded,
                    color: _info, size: SizeConfig.res(4.5)),
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
          _styledField(
              'Job Done On Vehicle', controller.jobDoneOnVehicleController),
          SizedBox(height: SizeConfig.sh(0.016)),
          _sectionLabel('Charges & Dates'),
          _twoCol(
            _styledField('Labour Charge', controller.labourChargeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.updateTotals()),
            _styledDatePicker(context, 'Received Date', controller.receivedDate),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _twoCol(
            _styledDatePicker(context, 'Delivery Date', controller.deliveryDate,
                required: true),
            _readonlyDateWidget('Follow Up Date', controller.followUpDate),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          _readonlyDateWidget(
              'Post Service Feedback Date', controller.postServiceFeedbackDate),
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
                horizontal: SizeConfig.sw(0.012),
                vertical: SizeConfig.sh(0.009)),
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
                        fontWeight:
                            value.value ? FontWeight.w600 : FontWeight.w400)),
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
                style:
                    TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4))),
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
                labelStyle:
                    TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                labelStyle:
                    TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  _totalCol('Grand Total',
                      controller.totalAmount.toStringAsFixed(2), _textDark),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount %',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      Row(children: [
                        SizedBox(
                          width: SizeConfig.sw(0.05),
                          height: SizeConfig.sh(0.055),
                          child: TextField(
                            controller: controller.discountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize: SizeConfig.res(3.2),
                                color: _textDark),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
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
                        SizedBox(width: SizeConfig.sw(0.01)),
                        Text(
                            '(${controller.discountAmount.toStringAsFixed(0)})',
                            style: TextStyle(
                                fontSize: SizeConfig.res(3.2),
                                fontWeight: FontWeight.w700,
                                color: _danger)),
                      ]),
                    ],
                  ),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  _totalCol('Net Total',
                      controller.netAmount.toStringAsFixed(2), _primary,
                      isBold: true),
                  SizedBox(width: SizeConfig.sw(0.04)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paid Amount',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      SizedBox(
                        width: SizeConfig.sw(0.1),
                        height: SizeConfig.sh(0.055),
                        child: TextField(
                          controller: controller.paidAmountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textDark),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: _success, width: 1.5),
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
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
                      SizedBox(height: SizeConfig.sh(0.005)),
                      SizedBox(
                        width: SizeConfig.sw(0.1),
                        child: DropdownButtonFormField<String>(
                          value: paidFromOptions.contains(paidFrom.value)
                              ? paidFrom.value
                              : null,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textDark),
                          items: paidFromOptions
                              .map((p) => DropdownMenuItem(
                                  value: p, child: Text(p.toUpperCase())))
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
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

  Widget _totalCol(String label, String value, Color color,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.4), color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Search item...',
                      hintStyle: TextStyle(
                          color: _textMid, fontSize: SizeConfig.res(3.4)),
                      prefixIcon: Icon(Icons.search,
                          color: _textMid, size: SizeConfig.res(5)),
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
                            s.name
                                .toLowerCase()
                                .contains(searchCtrl.text.toLowerCase()) ||
                            s.itemNo
                                .toLowerCase()
                                .contains(searchCtrl.text.toLowerCase()))
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(
                          child: Text('No items found',
                              style: TextStyle(
                                  color: _textMid,
                                  fontSize: SizeConfig.res(3.5))));
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: SizeConfig.res(3.6),
                                                color: isDisabled
                                                    ? _textMid
                                                    : _textDark)),
                                        Text('No: ${s.itemNo}',
                                            style: TextStyle(
                                                fontSize: SizeConfig.res(3),
                                                color: _textMid)),
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
                                      Text(
                                          'Buy: Rs.${s.purchasePrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: SizeConfig.res(3.2),
                                              fontWeight: FontWeight.w600,
                                              color: _textDark)),
                                      Text(
                                          'Sell: Rs.${s.salePrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: SizeConfig.res(3),
                                              color: _primary)),
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

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}
