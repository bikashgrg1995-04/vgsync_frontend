import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class PurchaseDetailPage extends StatefulWidget {
  final PurchaseModel purchase;
  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final PurchaseController controller = Get.find<PurchaseController>();
  final StockController stockController = Get.find<StockController>();
  final SupplierController supplierController = Get.find();
  final StaffController staffController = Get.find();

  // ── Color aliases ─────────────────────────────────────────────────────────
  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _success  = AppColors.success;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.populateForm(widget.purchase);
      controller.clearModifiedFlag();
    });
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
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoStrip(),
            SizedBox(height: SizeConfig.sh(0.02)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildTableSection(),
            SizedBox(height: SizeConfig.sh(0.016)),
            _buildTotals(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
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
          Text(
            'Purchase Details',
            style: TextStyle(
              fontSize: SizeConfig.res(4.8),
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'PO #${widget.purchase.id ?? "-"}',
            style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid),
          ),
        ],
      ),
      actions: [
        Obx(() {
          if (!controller.isModified.value) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(right: SizeConfig.sw(0.012)),
            child: GestureDetector(
              onTap: _savePurchase,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.016),
                  vertical: SizeConfig.sh(0.010),
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, size: SizeConfig.res(4), color: _surface),
                    SizedBox(width: SizeConfig.sw(0.005)),
                    Text(
                      'Save',
                      style: TextStyle(
                        fontSize: SizeConfig.res(3.4),
                        fontWeight: FontWeight.w700,
                        color: _surface,
                      ),
                    ),
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

  // ── Info strip ────────────────────────────────────────────────────────────
  Widget _buildInfoStrip() {
    final status = widget.purchase.status;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.016),
        vertical: SizeConfig.sh(0.014),
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Status accent
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
                _infoTile(
                  icon: Icons.tag_rounded,
                  label: 'Order ID',
                  value: '#${widget.purchase.id ?? "-"}',
                ),
                _verticalDivider(),
                _infoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: widget.purchase.date.toIso8601String().split('T')[0],
                ),
                _verticalDivider(),
                _infoTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Supplier',
                  value: supplierController.suppliers
                      .firstWhere(
                        (s) => s.id == widget.purchase.supplier,
                        orElse: () => supplierController.suppliers.first,
                      )
                      .name,
                ),
                _verticalDivider(),
                // Status pill
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
                    SizedBox(height: SizeConfig.sh(0.004)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.010),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
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
              Text(
                value,
                style: TextStyle(
                  fontSize: SizeConfig.res(3.4),
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: SizeConfig.sh(0.05),
      color: _border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
    );
  }

  // ── Header: dropdowns + paid ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _styledDateField()),
              SizedBox(width: SizeConfig.sw(0.012)),
              Expanded(child: _supplierDropdown()),
              SizedBox(width: SizeConfig.sw(0.012)),
              Expanded(child: _staffDropdown()),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          _paidAmountField(),
        ],
      ),
    );
  }

  Widget _styledDateField() {
    return TextField(
      controller: controller.dateController,
      readOnly: true,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      decoration: InputDecoration(
        labelText: 'Purchase Date',
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        suffixIcon: Icon(Icons.calendar_today_rounded, size: SizeConfig.res(4.5), color: _primary),
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
      onTap: () => controller.pickPurchaseDate(context),
    );
  }

  Widget _supplierDropdown() {
    return Obx(() {
      if (supplierController.suppliers.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      return DropdownButtonFormField<int>(
        value: controller.selectedSupplierId.value,
        style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
        decoration: InputDecoration(
          labelText: 'Supplier',
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
        items: supplierController.suppliers
            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
            .toList(),
        onChanged: (v) {
          controller.selectedSupplierId.value = v;
          controller.isModified.value = true;
        },
      );
    });
  }

  Widget _staffDropdown() {
    return Obx(() {
      if (staffController.staffs.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      return DropdownButtonFormField<int>(
        value: controller.selectedStaffId.value,
        style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
        decoration: InputDecoration(
          labelText: 'Created By',
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
        items: staffController.staffs
            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
            .toList(),
        onChanged: (v) {
          controller.selectedStaffId.value = v;
          controller.isModified.value = true;
        },
      );
    });
  }

  Widget _paidAmountField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller.paidController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
            decoration: InputDecoration(
              labelText: 'Paid Amount',
              labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.008)),
                child: Text(
                  'Rs.',
                  style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w700,
                    color: _success,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _success, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border),
              ),
            ),
            onChanged: (_) => controller.isModified.value = true,
          ),
        ),
        SizedBox(width: SizeConfig.sw(0.012)),
        // Add item button here for convenient access
        GestureDetector(
          onTap: _openStockPicker,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.018),
              vertical: SizeConfig.sh(0.018),
            ),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: SizeConfig.res(4.5), color: _primary),
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
      ],
    );
  }

  // ── Item table ─────────────────────────────────────────────────────────────
  Widget _buildTableSection() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            _buildItemTableHeader(),
            Expanded(child: _buildItemList()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTableHeader() {
    return Container(
      height: SizeConfig.sh(0.05),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: SizeConfig.sw(0.04),
            child: Text('SN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          Expanded(
            child: Text('Item Name',
                style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )),
          ),
          SizedBox(
            width: SizeConfig.sw(0.07),
            child: Text('Qty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(
            width: SizeConfig.sw(0.09),
            child: Text('Rate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          SizedBox(
            width: SizeConfig.sw(0.09),
            child: Text('Total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.res(3),
                  fontWeight: FontWeight.w700,
                  color: _primary,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.036)),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return Obx(() => ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, index) {
            final item = controller.items[index];
            final isEven = index.isEven;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.012),
                vertical: SizeConfig.sh(0.008),
              ),
              decoration: BoxDecoration(
                color: isEven ? _bg : _surface,
                border: Border(bottom: BorderSide(color: _border.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.04),
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.res(3.2),
                        color: _textMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.008)),
                  Expanded(
                    child: Text(
                      item.itemName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeConfig.res(3.4),
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.07),
                    height: SizeConfig.sh(0.042),
                    child: TextField(
                      controller: item.quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.sh(0.01),
                          horizontal: SizeConfig.sw(0.004),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _primary, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _border),
                        ),
                      ),
                      onChanged: (_) => controller.isModified.value = true,
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.008)),
                  SizedBox(
                    width: SizeConfig.sw(0.09),
                    height: SizeConfig.sh(0.042),
                    child: TextField(
                      controller: item.priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: SizeConfig.res(3.2), color: _textDark),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: SizeConfig.sh(0.01),
                          horizontal: SizeConfig.sw(0.004),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _primary, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _border),
                        ),
                      ),
                      onChanged: (_) => controller.isModified.value = true,
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.008)),
                  SizedBox(
                    width: SizeConfig.sw(0.09),
                    child: Obx(() => Text(
                          'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.res(3.2),
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        )),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.036),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.delete_outline_rounded,
                          size: SizeConfig.res(4.5), color: _danger),
                      onPressed: () => controller.removeItem(item),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  // ── Totals ─────────────────────────────────────────────────────────────────
  Widget _buildTotals() {
    return Obx(() => Container(
          padding: EdgeInsets.all(SizeConfig.res(4)),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              _totalTile(
                label: 'Grand Total',
                value: controller.grandTotal,
                color: _textDark,
                icon: Icons.account_balance_wallet_outlined,
              ),
              _verticalDivider(),
              _totalTile(
                label: 'Discount',
                value: controller.discountAmount,
                color: _warning,
                icon: Icons.local_offer_outlined,
              ),
              _verticalDivider(),
              _totalTile(
                label: 'Net Total',
                value: controller.netTotal,
                color: _primary,
                icon: Icons.receipt_outlined,
                isBold: true,
              ),
              _verticalDivider(),
              _totalTile(
                label: 'Remaining',
                value: controller.remaining.value,
                color: controller.remaining.value > 0 ? _danger : _success,
                icon: Icons.pending_outlined,
                isBold: true,
              ),
            ],
          ),
        ));
  }

  Widget _totalTile({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    bool isBold = false,
  }) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
              SizedBox(height: SizeConfig.sh(0.003)),
              Text(
                'Rs. ${value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: SizeConfig.res(isBold ? 4 : 3.6),
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  void _savePurchase() async {
    try {
      final updatedItems = controller.items.map((i) => i.toModel()).toList();
      final updatedPurchase = widget.purchase.copyWith(
        items: updatedItems,
        paidAmount: double.tryParse(controller.paidController.text) ?? 0,
        discountAmount: controller.discountAmount,
        supplier: controller.selectedSupplierId.value,
        createdBy: controller.selectedStaffId.value,
      );
      await controller.updatePurchase(updatedPurchase);
      controller.populateForm(updatedPurchase);
      controller.clearModifiedFlag();
    } catch (_) {}
  }

  // ── Stock picker ───────────────────────────────────────────────────────────
  void _openStockPicker() async {
    final searchCtrl = TextEditingController();
    final StockModel? selected = await showDialog<StockModel>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                  decoration: InputDecoration(
                    hintText: 'Search stock...',
                    hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                    prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                  ),
                  onChanged: (_) => (searchCtrl).notifyListeners(),
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
                      child: Text('No stock found',
                          style: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.5))),
                    );
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context, s),
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.res(3.5)),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: SizeConfig.res(3.6),
                                          color: _textDark,
                                        ),
                                      ),
                                      Text(
                                        'No: ${s.itemNo}',
                                        style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.sw(0.008),
                                    vertical: SizeConfig.sh(0.005),
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Stock: ${s.stock}',
                                    style: TextStyle(
                                      fontSize: SizeConfig.res(3),
                                      fontWeight: FontWeight.w700,
                                      color: stockColor,
                                    ),
                                  ),
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
                                        color: _textDark,
                                      ),
                                    ),
                                    Text(
                                      'Sell: Rs.${s.salePrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: SizeConfig.res(3),
                                        color: _primary,
                                      ),
                                    ),
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
    );
    if (selected != null) controller.addItem(selected);
  }
}