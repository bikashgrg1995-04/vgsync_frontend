import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final ExpenseController controller =
      Get.put(ExpenseController(expenseRepository: Get.find()));
  final GlobalController globalController = Get.find<GlobalController>();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _success  = AppColors.success;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _info     = AppColors.info;
  static const _secondary = AppColors.secondary;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  // expense type → color
  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'salary':      return _primary;
      case 'operational': return _warning;
      case 'other':       return _info;
      default:            return _textMid;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'salary':      return Icons.people_outline;
      case 'operational': return Icons.settings_outlined;
      case 'other':       return Icons.category_outlined;
      default:            return Icons.receipt_outlined;
    }
  }

  Color _modeColor(String mode) =>
      mode.toLowerCase() == 'cash' ? _success : _info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchExpenses());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openExpenseDialog(),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Expense',
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
            SizedBox(height: SizeConfig.sh(0.014)),
            _buildFiltersRow(),
            SizedBox(height: SizeConfig.sh(0.014)),
            _buildSummary(),
            SizedBox(height: SizeConfig.sh(0.014)),
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
        Text('Expenses',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Track and manage all business expenses',
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
      ],
    );
  }

  // ── Header (search + refresh) ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
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
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                ),
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          _headerBtn(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            color: _primary,
            onPressed: controller.setDefaultFilters,
          ),
        ],
      ),
    );
  }

  Widget _headerBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
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

  // ── Filters row ────────────────────────────────────────────────────────────
  Widget _buildFiltersRow() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(3.5)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: _filterLabel('Date Filter',
                child: CommonDatePicker(
                  label: 'Select Date',
                  selectedDate: controller.selectedDate,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          Expanded(
            flex: 2,
            child: _filterLabel('Expense Type',
                child: Obx(() => _styledDropdown<String>(
                      value: controller.selectedExpenseType.value,
                      items: const ['All', 'Salary', 'Operational', 'Other'],
                      onChanged: (v) =>
                          controller.selectedExpenseType.value = v ?? 'All',
                    ))),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          Expanded(
            flex: 2,
            child: _filterLabel('Payment Mode',
                child: Obx(() => _styledDropdown<String>(
                      value: controller.selectedPaymentMode.value,
                      items: const ['All', 'Cash', 'Online'],
                      onChanged: (v) =>
                          controller.selectedPaymentMode.value = v ?? 'All',
                    ))),
          ),
        ],
      ),
    );
  }

  Widget _filterLabel(String label, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: SizeConfig.res(3.2),
                fontWeight: FontWeight.w600,
                color: _textMid)),
        SizedBox(height: SizeConfig.sh(0.006)),
        child,
      ],
    );
  }

  Widget _styledDropdown<T>({
    required T value,
    required List<String> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      decoration: InputDecoration(
        filled: true,
        fillColor: _bg,
        contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.012), vertical: SizeConfig.sh(0.014)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border)),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e as T,
                child: Text(e,
                    style: TextStyle(
                        fontSize: SizeConfig.res(3.4), color: _textDark)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── Summary cards ──────────────────────────────────────────────────────────
  Widget _buildSummary() {
    return Obx(() {
      final list = controller.filteredExpenses;
      final total = list.fold<double>(0, (s, e) => s + e.amount);
      final cash = list
          .where((e) => e.paymentMode.toLowerCase() == 'cash')
          .fold<double>(0, (s, e) => s + e.amount);
      final online = list
          .where((e) => e.paymentMode.toLowerCase() == 'online')
          .fold<double>(0, (s, e) => s + e.amount);

      return Row(
        children: [
          _summaryTile(Icons.account_balance_wallet_outlined, 'Total', total, _primary),
          SizedBox(width: SizeConfig.sw(0.01)),
          _summaryTile(Icons.payments_outlined, 'Cash', cash, _success),
          SizedBox(width: SizeConfig.sw(0.01)),
          _summaryTile(Icons.account_balance_outlined, 'Online', online, _info),
        ],
      );
    });
  }

  Widget _summaryTile(IconData icon, String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.016)),
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
              padding: EdgeInsets.all(SizeConfig.res(2.5)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: SizeConfig.res(5), color: color),
            ),
            SizedBox(width: SizeConfig.sw(0.012)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: SizeConfig.res(3), color: _textMid)),
                SizedBox(height: SizeConfig.sh(0.003)),
                Text('Rs. ${value.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: SizeConfig.res(4.2),
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
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

      final list = controller.filteredExpenses.reversed.toList();

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No expenses found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: list.length,
        itemBuilder: (_, i) => _expenseTile(list[i]),
      );
    });
  }

  Widget _expenseTile(ExpenseModel expense) {
    final editable = expense.isEditable;
    final typeColor = _typeColor(expense.expenseType);
    final modeColor = _modeColor(expense.paymentMode);
    final icon = _typeIcon(expense.expenseType);

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      child: Slidable(
        key: ValueKey(expense.id),
        endActionPane: editable
            ? ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.28,
                children: [
                  SlidableAction(
                    onPressed: (_) => openExpenseDialog(expense),
                    backgroundColor: _warning,
                    foregroundColor: _surface,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                  ),
                  SlidableAction(
                    onPressed: (_) => controller.deleteExpense(expense),
                    backgroundColor: _danger,
                    foregroundColor: _surface,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12)),
                  ),
                ],
              )
            : null,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.res(3.5)),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: editable ? _border : _border.withOpacity(0.5),
            ),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              // accent bar
              Container(
                width: SizeConfig.sw(0.005),
                height: SizeConfig.sh(0.075),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              // type icon
              Container(
                padding: EdgeInsets.all(SizeConfig.res(2.5)),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: typeColor, size: SizeConfig.res(5.5)),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(expense.title,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.8),
                                  fontWeight: FontWeight.w700,
                                  color: _textDark),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text('Rs. ${expense.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: SizeConfig.res(4),
                                fontWeight: FontWeight.w800,
                                color: _danger)),
                      ],
                    ),
                    SizedBox(height: SizeConfig.sh(0.005)),
                    Row(
                      children: [
                        _typeBadge(expense.expenseType, typeColor),
                        SizedBox(width: SizeConfig.sw(0.008)),
                        _modeBadge(expense.paymentMode, modeColor),
                        SizedBox(width: SizeConfig.sw(0.012)),
                        Icon(Icons.calendar_today_outlined,
                            size: SizeConfig.res(3.2), color: _textMid),
                        SizedBox(width: SizeConfig.sw(0.004)),
                        Text(
                          expense.expenseDate
                              .toIso8601String()
                              .split('T')
                              .first,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid),
                        ),
                        if (!editable) ...[
                          SizedBox(width: SizeConfig.sw(0.01)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.sw(0.006),
                                vertical: SizeConfig.sh(0.003)),
                            decoration: BoxDecoration(
                              color: _textMid.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Auto',
                                style: TextStyle(
                                    fontSize: SizeConfig.res(2.6),
                                    color: _textMid)),
                          ),
                        ],
                      ],
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty) ...[
                      SizedBox(height: SizeConfig.sh(0.004)),
                      Row(
                        children: [
                          Icon(Icons.notes_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Expanded(
                            child: Text(expense.note!,
                                style: TextStyle(
                                    fontSize: SizeConfig.res(3), color: _textMid),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(type.capitalizeFirst ?? type,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _modeBadge(String mode, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mode.toLowerCase() == 'cash'
                ? Icons.payments_outlined
                : Icons.account_balance_outlined,
            size: SizeConfig.res(3),
            color: color,
          ),
          SizedBox(width: SizeConfig.sw(0.003)),
          Text(mode.capitalizeFirst ?? mode,
              style: TextStyle(
                  fontSize: SizeConfig.res(2.8),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
  void openExpenseDialog([ExpenseModel? expense]) {
    final isEdit = expense != null;
    if (isEdit) {
      controller.fillForm(expense);
    } else {
      controller.clearForm();
      controller.saleDate.value = DateTime.now();
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Expense' : 'Add Expense',
        isEditMode: isEdit,
        height: 0.78,
        width: 0.28,
        content: _expenseForm(),
        onSave: () async {
          if (isEdit) {
            await controller.updateExpense(expense);
            Get.back(closeOverlays: true);
            DesktopToast.show('Expense updated successfully',
                backgroundColor: _success);
          } else {
            await controller.addExpense();
            Get.back(closeOverlays: true);
            DesktopToast.show('Expense added successfully',
                backgroundColor: _success);
          }
        },
      ),
    );
  }

  Widget _expenseForm() {
    return Column(
      children: [
        CommonDatePicker(
          label: 'Expense Date',
          selectedDate: controller.saleDate,
        ),
        SizedBox(height: SizeConfig.sh(0.016)),
        _dialogField(controller.titleCtrl, 'Title', Icons.title),
        SizedBox(height: SizeConfig.sh(0.016)),
        _dialogDropdown(
          controller.paymentModeRx,
          'Payment Mode',
          const ['Cash', 'Online'],
          icon: Icons.account_balance_wallet_outlined,
        ),
        SizedBox(height: SizeConfig.sh(0.016)),
        _dialogDropdown(
          controller.expenseTypeRx,
          'Expense Type',
          const ['All', 'Salary', 'Operational', 'Other'],
          icon: Icons.category_outlined,
        ),
        SizedBox(height: SizeConfig.sh(0.016)),
        _dialogField(controller.amountCtrl, 'Amount', Icons.currency_rupee,
            keyboardType: TextInputType.number),
        SizedBox(height: SizeConfig.sh(0.016)),
        _dialogField(controller.noteCtrl, 'Note', Icons.notes_outlined),
      ],
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

  Widget _dialogDropdown(
      RxString rx, String label, List<String> options, {required IconData icon}) {
    return Obx(() => DropdownButtonFormField<String>(
          value: options.contains(rx.value) ? rx.value : null,
          style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
          decoration: InputDecoration(
            labelText: label,
            labelStyle:
                TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
            prefixIcon: Icon(icon, size: SizeConfig.res(4.5), color: _primary),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border)),
          ),
          items: options
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.4), color: _textDark)),
                  ))
              .toList(),
          onChanged: (v) => rx.value = v ?? options.first,
        ));
  }
}