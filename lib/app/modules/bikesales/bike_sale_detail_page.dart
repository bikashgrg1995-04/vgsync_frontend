import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class BikeSaleDetailPage extends StatefulWidget {
  final BikeSale sale;
  const BikeSaleDetailPage({super.key, required this.sale});

  @override
  State<BikeSaleDetailPage> createState() => _BikeSaleDetailPageState();
}

class _BikeSaleDetailPageState extends State<BikeSaleDetailPage> {
  final BikeSaleController controller = Get.find<BikeSaleController>();
  final GlobalController globalController = Get.find<GlobalController>();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEmiTrackers(widget.sale.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Obx(() {
        final sale = controller.bikeSales.firstWhere(
          (s) => s.id == widget.sale.id,
          orElse: () => widget.sale,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.res(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoStrip(sale),
              SizedBox(height: SizeConfig.sh(0.018)),
              _detailsRow(sale),
              SizedBox(height: SizeConfig.sh(0.018)),
              if (sale.isEmi || sale.saleType == SaleType.downpayment)
                _emiSection(sale.id),
              SizedBox(height: SizeConfig.sh(0.03)),
            ],
          ),
        );
      }),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
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
          child: Icon(Icons.arrow_back_rounded, color: _textDark, size: SizeConfig.res(5)),
        ),
      ),
      title: Obx(() {
        final sale = controller.bikeSales.firstWhere(
          (s) => s.id == widget.sale.id,
          orElse: () => widget.sale,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sale.customerName.capitalizeFirst ?? '',
                style: TextStyle(
                    fontSize: SizeConfig.res(4.8),
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.3)),
            Text(sale.vehicleModel,
                style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
          ],
        );
      }),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.sw(0.012)),
          child: Container(
            padding: EdgeInsets.all(SizeConfig.res(2.5)),
            decoration: BoxDecoration(
              color: _info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _info.withOpacity(0.25)),
            ),
            child: Icon(
              widget.sale.vehicleType == VehicleType.bike
                  ? Icons.two_wheeler
                  : Icons.electric_scooter,
              color: _info,
              size: SizeConfig.res(6),
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
  Widget _infoStrip(BikeSale sale) {
    final isPending = sale.remainingAmount > 0;
    final statusColor = isPending ? _warning : _success;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.014)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: SizeConfig.sw(0.006),
            height: SizeConfig.sh(0.06),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.014)),
          Expanded(
            child: Row(
              children: [
                _stripTile(Icons.calendar_today_rounded, 'Date',
                    sale.saleDate.toIso8601String().split('T')[0]),
                _vDivider(),
                _stripTile(Icons.phone_outlined, 'Contact', sale.contactNo),
                _vDivider(),
                _stripTile(Icons.payments_outlined, 'Payment',
                    sale.paymentMethod.name.toUpperCase()),
                _vDivider(),
                _stripTile(Icons.sell_outlined, 'Sale Type',
                    sale.saleType.name.capitalizeFirst ?? ''),
                _vDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
                    SizedBox(height: SizeConfig.sh(0.004)),
                    _statusPill(isPending ? 'PENDING' : 'PAID', statusColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stripTile(IconData icon, String label, String value) {
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
              Text(label, style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
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

  Widget _vDivider() {
    return Container(
      width: 1,
      height: SizeConfig.sh(0.05),
      color: _border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
    );
  }

  // ── Details row ────────────────────────────────────────────────────────────
  Widget _detailsRow(BikeSale sale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _customerCard(sale)),
        SizedBox(width: SizeConfig.sw(0.015)),
        Expanded(child: _vehicleCard(sale)),
        SizedBox(width: SizeConfig.sw(0.015)),
        Expanded(child: _paymentCard(sale)),
      ],
    );
  }

  Widget _customerCard(BikeSale sale) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.person_outline_rounded, 'Customer'),
          SizedBox(height: SizeConfig.sh(0.014)),
          _infoItem('Name', sale.customerName.capitalizeFirst ?? ''),
          _infoItem('Contact', sale.contactNo),
          _infoItem('Address', sale.address?.capitalizeFirst ?? '-'),
        ],
      ),
    );
  }

  Widget _vehicleCard(BikeSale sale) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.two_wheeler, 'Vehicle'),
          SizedBox(height: SizeConfig.sh(0.014)),
          _infoItem('Type', sale.vehicleType.name.capitalizeFirst ?? ''),
          _infoItem('Model', sale.vehicleModel.capitalizeFirst ?? ''),
          _infoItem('Reg. No', sale.registrationNo),
          _infoItem('Chassis', sale.chassisNo),
          _infoItem('Engine', sale.engineNo),
          if (sale.color != null && sale.color!.isNotEmpty)
            _infoItem('Color', sale.color!),
          if (sale.kmDriven != null && sale.kmDriven > 0)
            _infoItem('KM Driven', '${sale.kmDriven} km'),
        ],
      ),
    );
  }

  Widget _paymentCard(BikeSale sale) {
    final isPending = sale.remainingAmount > 0;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.account_balance_wallet_outlined, 'Payment'),
          SizedBox(height: SizeConfig.sh(0.014)),
          _infoItem('Sale Type', sale.saleType.name.capitalizeFirst ?? ''),
          _infoItem('Method', sale.paymentMethod.name.toUpperCase()),
          SizedBox(height: SizeConfig.sh(0.012)),
          _totalTile(Icons.receipt_outlined, 'Net Total', sale.netTotal, _primary),
          SizedBox(height: SizeConfig.sh(0.008)),
          if (sale.saleType == SaleType.downpayment)
            _totalTile(Icons.payment, 'Down Payment', sale.initialPaidAmount.toDouble(), _info),
          SizedBox(height: SizeConfig.sh(0.008)),
          _totalTile(Icons.check_circle_outline, 'Total Paid', sale.paidAmount, _success),
          SizedBox(height: SizeConfig.sh(0.008)),
          _totalTile(Icons.pending_outlined, 'Remaining', sale.remainingAmount,
              isPending ? _danger : _success),
          if (sale.isEmi || sale.saleType == SaleType.downpayment) ...[
            SizedBox(height: SizeConfig.sh(0.012)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.01), vertical: SizeConfig.sh(0.008)),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EMI Amount',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.2), color: _textMid)),
                  Text('Rs. ${sale.emiAmount?.toStringAsFixed(0) ?? "-"}',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.4),
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ],
              ),
            ),
          ],
          if (sale.remarks != null && sale.remarks!.isNotEmpty) ...[
            SizedBox(height: SizeConfig.sh(0.012)),
            _infoItem('Remarks', sale.remarks!),
          ],
        ],
      ),
    );
  }

  // ── EMI Section ────────────────────────────────────────────────────────────
  Widget _emiSection(int saleId) {
    return _card(
      child: Obx(() {
        final filteredList = controller.getFilteredEmis(saleId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardTitle(Icons.schedule_rounded, 'EMI Schedule'),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.01), vertical: SizeConfig.sh(0.006)),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: ${filteredList.whereType<EmiTracker>().length}',
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.2),
                        fontWeight: FontWeight.w600,
                        color: _primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.014)),
            // Filter buttons
            Row(
              children: ['all', 'pending', 'paid'].map((f) {
                final isSelected = controller.emiFilter.value == f;
                final color = f == 'paid' ? _success : f == 'pending' ? _warning : _primary;
                return Padding(
                  padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
                  child: GestureDetector(
                    onTap: () => controller.emiFilter.value = f,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.009)),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3)),
                      ),
                      child: Text(f.capitalizeFirst ?? f,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3),
                              fontWeight: FontWeight.w600,
                              color: isSelected ? _surface : color)),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: SizeConfig.sh(0.014)),
            if (filteredList.isEmpty)
              _emptyEmi()
            else
              Column(
                children: filteredList.map((emi) {
                  if (emi == null) return _emptyEmi();
                  return _emiCard(emi);
                }).toList(),
              ),
          ],
        );
      }),
    );
  }

  Widget _emiCard(EmiTracker emi) {
    final isPaid = emi.paidAmount >= emi.amountDue;
    final isPartial = emi.paidAmount > 0 && emi.paidAmount < emi.amountDue;
    final paidPercent = (emi.paidAmount / emi.amountDue).clamp(0.0, 1.0);
    final Color statusColor = isPaid ? _success : isPartial ? _warning : _warning;

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.01)),
      padding: EdgeInsets.all(SizeConfig.res(3.5)),
      decoration: BoxDecoration(
        color: isPaid ? _success.withOpacity(0.03) : _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? _success.withOpacity(0.2)
              : isPartial
                  ? _warning.withOpacity(0.2)
                  : _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeConfig.res(2)),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: SizeConfig.res(4),
                      color: statusColor,
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.01)),
                  Text('Installment ${emi.installmentNo}',
                      style: TextStyle(
                          fontSize: SizeConfig.res(3.6),
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ],
              ),
              if (!isPaid)
                GestureDetector(
                  onTap: () =>
                      _showUpdateEmiDialog(Get.context!, emi, widget.sale.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.014),
                        vertical: SizeConfig.sh(0.010)),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Pay Now',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.2),
                            fontWeight: FontWeight.w700,
                            color: _surface)),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.010),
                      vertical: SizeConfig.sh(0.005)),
                  decoration: BoxDecoration(
                    color: _success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: SizeConfig.res(3.5), color: _success),
                      SizedBox(width: SizeConfig.sw(0.004)),
                      Text('Paid',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3),
                              fontWeight: FontWeight.w700,
                              color: _success)),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: paidPercent,
              backgroundColor: _border,
              color: statusColor,
              minHeight: SizeConfig.sh(0.012),
            ),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          Row(
            children: [
              _emiChip(Icons.calendar_today_outlined, 'Due',
                  emi.dueDate.toIso8601String().split('T')[0]),
              SizedBox(width: SizeConfig.sw(0.02)),
              _emiChip(Icons.money_outlined, 'Amount',
                  'Rs. ${emi.amountDue.toStringAsFixed(0)}'),
              SizedBox(width: SizeConfig.sw(0.02)),
              _emiChip(Icons.check_circle_outline, 'Paid',
                  'Rs. ${emi.paidAmount.toStringAsFixed(0)}',
                  color: isPaid ? _success : isPartial ? _warning : _textMid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emiChip(IconData icon, String label, String value, {Color? color}) {
    final c = color ?? _textMid;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeConfig.res(3.2), color: c),
        SizedBox(width: SizeConfig.sw(0.004)),
        Text('$label: ',
            style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
        Text(value,
            style: TextStyle(
                fontSize: SizeConfig.res(3.2),
                fontWeight: FontWeight.w600,
                color: c)),
      ],
    );
  }

  Widget _emptyEmi() {
    return Container(
      height: SizeConfig.sh(0.08),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Text('No EMI records',
          style: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4))),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _card({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2.2)),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4.5), color: _primary),
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

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SizeConfig.sw(0.1),
            child: Text(label,
                style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid)),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
          ),
        ],
      ),
    );
  }

  Widget _totalTile(IconData icon, String label, double value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4), color: color),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
              Text('Rs. ${value.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.6),
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ],
    );
  }

  // ── EMI Update dialog ──────────────────────────────────────────────────────
  void _showUpdateEmiDialog(BuildContext context, EmiTracker emi, int saleId) {
    final amountCtrl =
        TextEditingController(text: emi.paidAmount.toStringAsFixed(0));
    final dateCtrl = TextEditingController(
        text: (emi.paymentDate ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first);
    var selectedMethod = emi.paymentMethod ?? EMIPaymentMethod.cash;
    var selectedStatus =
        emi.paidAmount >= emi.amountDue ? EmiStatus.paid : EmiStatus.pending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update EMI #${emi.installmentNo}',
            style: TextStyle(
                fontSize: SizeConfig.res(4.5),
                fontWeight: FontWeight.w700,
                color: _textDark),
          ),
          content: SizedBox(
            width: SizeConfig.sw(0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(amountCtrl, 'Paid Amount', Icons.money,
                    keyboardType: TextInputType.number, onChanged: (v) {
                  final val = double.tryParse(v) ?? 0.0;
                  setState(() {
                    selectedStatus =
                        val >= emi.amountDue ? EmiStatus.paid : EmiStatus.pending;
                  });
                }),
                SizedBox(height: SizeConfig.sh(0.016)),
                _dialogField(dateCtrl, 'Payment Date (YYYY-MM-DD)', Icons.calendar_today_rounded),
                SizedBox(height: SizeConfig.sh(0.016)),
                DropdownButtonFormField<EMIPaymentMethod>(
                  value: selectedMethod,
                  style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                    prefixIcon: Icon(Icons.payments_outlined,
                        size: SizeConfig.res(4.5), color: _primary),
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
                  items: EMIPaymentMethod.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedMethod = v);
                  },
                ),
                SizedBox(height: SizeConfig.sh(0.016)),
                Row(
                  children: [
                    Text('Status: ',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.4), color: _textMid)),
                    SizedBox(width: SizeConfig.sw(0.008)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.012),
                          vertical: SizeConfig.sh(0.007)),
                      decoration: BoxDecoration(
                        color: (selectedStatus == EmiStatus.paid
                                ? _success
                                : _warning)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (selectedStatus == EmiStatus.paid
                                  ? _success
                                  : _warning)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        selectedStatus.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: SizeConfig.res(3),
                          fontWeight: FontWeight.w700,
                          color: selectedStatus == EmiStatus.paid
                              ? _success
                              : _warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.016),
                    vertical: SizeConfig.sh(0.012)),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Text('Cancel',
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.4), color: _textMid)),
              ),
            ),
            SizedBox(width: SizeConfig.sw(0.008)),
            Obx(() {
              final isLoading = controller.isEmiLoading.value;
              return GestureDetector(
                onTap: isLoading
                    ? null
                    : () async {
                        final paid = double.tryParse(amountCtrl.text) ?? emi.paidAmount;
                        final date = DateTime.tryParse(dateCtrl.text) ?? DateTime.now();
                        await controller.updateEmiPayment(
                          emiId: emi.id,
                          paidAmount: paid,
                          paymentDate: date,
                          paymentMethod: selectedMethod,
                          status: selectedStatus,
                          parentSaleId: saleId,
                        );
                        await controller.fetchBikeSales();
                        await controller.fetchEmiTrackers(saleId);
                        globalController.triggerRefresh(DashboardRefreshType.all);
                        if (Get.isDialogOpen ?? false) Get.back(closeOverlays: true);
                        DesktopToast.show(
                          'EMI Updated for ${date.toIso8601String().split('T').first}',
                          backgroundColor: _success,
                        );
                        Navigator.pop(context);
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.016),
                      vertical: SizeConfig.sh(0.012)),
                  decoration: BoxDecoration(
                    color: isLoading ? _border : _primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: SizeConfig.res(4),
                          height: SizeConfig.res(4),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _surface),
                        )
                      : Text('Update',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4),
                              fontWeight: FontWeight.w700,
                              color: _surface)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon,
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
        prefixIcon:
            Icon(icon, size: SizeConfig.res(4.5), color: _primary),
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