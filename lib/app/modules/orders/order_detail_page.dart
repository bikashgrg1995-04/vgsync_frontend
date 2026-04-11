import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/order_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_form_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

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
    formCtrl = Get.find<OrderFormController>();
    if (stockCtrl.stocks.isNotEmpty) formCtrl.fillFromOrder(widget.order);
    ever(stockCtrl.stocks, (_) {
      if (formCtrl.items.isEmpty && stockCtrl.stocks.isNotEmpty) {
        formCtrl.fillFromOrder(widget.order);
      }
    });
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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoStrip(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _detailsAndTotalsRow(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _itemsSection(),
            SizedBox(height: SizeConfig.sh(0.03)),
          ],
        ),
      ),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Details',
              style: TextStyle(
                  fontSize: SizeConfig.res(4.8),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.3)),
          Text('#${widget.order.id}',
              style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
        ],
      ),
      actions: [
        Obx(() {
          if (!formCtrl.isModified.value) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(right: SizeConfig.sw(0.012)),
            child: GestureDetector(
              onTap: _saveOrder,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.010)),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, size: SizeConfig.res(4), color: _surface),
                    SizedBox(width: SizeConfig.sw(0.005)),
                    Text('Save',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.4),
                            fontWeight: FontWeight.w700,
                            color: _surface)),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ── Info strip ─────────────────────────────────────────────────────────────
  Widget _infoStrip() {
    final status = widget.order.status;
    final statusColor = _statusColor(status);

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
                _stripTile(Icons.person_outline_rounded, 'Customer', widget.order.customerName),
                _vDivider(),
                _stripTile(Icons.phone_outlined, 'Contact', widget.order.contactNo),
                _vDivider(),
                _stripTile(Icons.bike_scooter_outlined, 'Vehicle', widget.order.vehicleModel),
                _vDivider(),
                _stripTile(Icons.calendar_today_rounded, 'Date',
                    widget.order.orderDate.toIso8601String().split('T')[0]),
                _vDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
                    SizedBox(height: SizeConfig.sh(0.004)),
                    _statusPill(status, statusColor),
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

  Widget _vDivider() {
    return Container(
      width: 1,
      height: SizeConfig.sh(0.05),
      color: _border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
    );
  }

  // ── Details + Totals row ───────────────────────────────────────────────────
  Widget _detailsAndTotalsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _advanceCard()),
        SizedBox(width: SizeConfig.sw(0.015)),
        Expanded(flex: 4, child: _totalsCard()),
      ],
    );
  }

  Widget _advanceCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.info_outline_rounded, 'Order Info'),
          SizedBox(height: SizeConfig.sh(0.014)),
          _infoItem('Order ID', '#${widget.order.id}'),
          _infoItem('Date', widget.order.orderDate.toIso8601String().split('T')[0]),
          _infoItem('Customer', widget.order.customerName),
          _infoItem('Contact', widget.order.contactNo),
          _infoItem('Vehicle', widget.order.vehicleModel),
          _infoItem('Status', widget.order.status.capitalizeFirst ?? ''),
        ],
      ),
    );
  }

  Widget _totalsCard() {
    return Obx(() => _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(Icons.account_balance_wallet_outlined, 'Payment Summary'),
              SizedBox(height: SizeConfig.sh(0.016)),
              Row(
                children: [
                  _totalTile(Icons.receipt_outlined, 'Total Amount',
                      formCtrl.totalAmount, _primary),
                  _vDivider(),
                  _totalTile(Icons.payments_outlined, 'Advance Paid',
                      double.tryParse(formCtrl.advanceCtrl.text) ?? 0, _success),
                  _vDivider(),
                  _totalTile(Icons.pending_outlined, 'Remaining',
                      formCtrl.remainingAmount,
                      formCtrl.remainingAmount > 0 ? _danger : _success,
                      isBold: true),
                ],
              ),
            ],
          ),
        ));
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
                    style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
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

  // ── Items section ──────────────────────────────────────────────────────────
  Widget _itemsSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardTitle(Icons.inventory_2_outlined, 'Items'),
              GestureDetector(
                onTap: _openStockPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.010)),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: SizeConfig.res(4), color: _primary),
                      SizedBox(width: SizeConfig.sw(0.005)),
                      Text('Add Item',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2),
                              fontWeight: FontWeight.w600,
                              color: _primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.014)),
          _itemTableHeader(),
          Obx(() => Column(
                children: formCtrl.items
                    .asMap()
                    .entries
                    .map((e) => _itemRow(e.value, e.key))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _itemTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.01)),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          SizedBox(width: SizeConfig.sw(0.035),
              child: Text('SN', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.008)),
          Expanded(child: Text('Item',
              style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.07),
              child: Text('Qty', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(width: SizeConfig.sw(0.09),
              child: Text('Rate', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(width: SizeConfig.sw(0.09),
              child: Text('Total', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: _primary))),
          SizedBox(width: SizeConfig.sw(0.036)),
        ],
      ),
    );
  }

  Widget _itemRow(OrderItemForm item, int index) {
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
                style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
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
            child: Obx(() => Text(
                  'Rs. ${item.total.value.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.2),
                      fontWeight: FontWeight.w700,
                      color: _primary),
                )),
          ),
          SizedBox(
            width: SizeConfig.sw(0.036),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.delete_outline_rounded,
                  size: SizeConfig.res(4.5), color: _danger),
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
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primary, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border)),
    );
  }

  // ── Shared card helpers ────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
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
        children: [
          SizedBox(
            width: SizeConfig.sw(0.09),
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

  // ── Save ───────────────────────────────────────────────────────────────────
  void _saveOrder() async {
    final order = formCtrl.getOrderModel(id: widget.order.id);
    try {
      await orderCtrl.updateOrder(order);
      formCtrl.clearModifiedFlag();
    } catch (_) {}
  }

  // ── Stock picker ───────────────────────────────────────────────────────────
  void _openStockPicker() async {
    final searchCtrl = TextEditingController();

    final StockModel? selected = await showDialog<StockModel>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Stock',
              style: TextStyle(
                  fontSize: SizeConfig.res(4.5),
                  fontWeight: FontWeight.w700,
                  color: _textDark)),
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
                      hintText: 'Search stock...',
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
                  child: Obx(() {
                    final filtered = stockCtrl.stocks
                        .where((s) => s.name
                            .toLowerCase()
                            .contains(searchCtrl.text.toLowerCase()))
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
                        final stockColor = s.stock <= 0
                            ? _danger
                            : s.stock <= 5
                                ? _warning
                                : _success;
                        return Container(
                          margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              final existingIdx = formCtrl.items
                                  .indexWhere((e) => e.stock.id == s.id);
                              if (existingIdx != -1) {
                                Navigator.pop(context);
                                _showUpdateItemDialog(existingIdx);
                              } else {
                                Navigator.pop(context, s);
                              }
                            },
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
                                            style: TextStyle(
                                                fontSize: SizeConfig.res(3),
                                                color: _textMid)),
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

  // ── Update existing item dialog ────────────────────────────────────────────
  void _showUpdateItemDialog(int index) {
    final item = formCtrl.items[index];
    final qtyCtrl = TextEditingController(text: item.qtyCtrl.text);
    final rateCtrl = TextEditingController(text: item.rateCtrl.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update: ${item.stock.name}',
            style: TextStyle(
                fontSize: SizeConfig.res(4.5),
                fontWeight: FontWeight.w700,
                color: _textDark)),
        content: SizedBox(
          width: SizeConfig.sw(0.25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(qtyCtrl, 'Quantity', Icons.add_chart,
                  keyboardType: TextInputType.number),
              SizedBox(height: SizeConfig.sh(0.016)),
              _dialogField(rateCtrl, 'Rate', Icons.money_outlined,
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.012)),
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border)),
              child: Text('Cancel',
                  style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          GestureDetector(
            onTap: () {
              item.qtyCtrl.text = qtyCtrl.text;
              item.rateCtrl.text = rateCtrl.text;
              formCtrl.items.refresh();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.012)),
              decoration: BoxDecoration(
                  color: _primary, borderRadius: BorderRadius.circular(10)),
              child: Text('Save',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4),
                      fontWeight: FontWeight.w700,
                      color: _surface)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon,
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
}