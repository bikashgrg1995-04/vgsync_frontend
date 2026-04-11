import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../data/models/staff_model.dart';
import '../../themes/app_colors.dart';
import 'staff_controller.dart';
import '../../wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class StaffDetailPage extends StatefulWidget {
  final StaffModel staff;
  const StaffDetailPage({super.key, required this.staff});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  final StaffController controller = Get.find<StaffController>();
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

  static const _designationColors = {
    'admin':       AppColors.primary,
    'accountant':  AppColors.info,
    'technician':  AppColors.warning,
    'helper':      AppColors.success,
    'sales':       AppColors.secondary,
    'other':       AppColors.textSecondary,
  };

  Color _desgColor(String d) =>
      _designationColors[d.toLowerCase()] ?? _textMid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSalaryTrackers(widget.staff.id!);
      controller.fetchTransactions(widget.staff.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(SizeConfig.res(4)),
            child: Column(
              children: [
                _buildProfileCard(),
                SizedBox(height: SizeConfig.sh(0.016)),
                Obx(() {
                  final tracker = controller.salaryTrackers
                      .firstWhereOrNull((t) => t['staff'] == widget.staff.id);
                  if (tracker != null && widget.staff.salaryMode != 'daily') {
                    return _buildSalarySummary(tracker);
                  }
                  return const SizedBox();
                }),
              ],
            ),
          ),
          _buildTransactionList(),
        ],
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
        onTap: () => Get.offAndToNamed(AppRoutes.navigation),
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
          Text('Staff Details',
              style: TextStyle(
                  fontSize: SizeConfig.res(4.8),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.3)),
          Text(widget.staff.name,
              style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Obx(() {
      final tracker = controller.salaryTrackers
          .firstWhereOrNull((t) => t['staff'] == widget.staff.id);
      final desgColor = _desgColor(widget.staff.designation);
      final initials = widget.staff.name.trim().split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join()
          .toUpperCase();
      final isDaily = widget.staff.salaryMode == 'daily';

      return Container(
        padding: EdgeInsets.all(SizeConfig.res(4)),
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
            // avatar
            Container(
              width: SizeConfig.sw(0.06),
              height: SizeConfig.sw(0.06),
              decoration: BoxDecoration(
                color: desgColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: desgColor.withOpacity(0.35), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(initials,
                  style: TextStyle(
                      fontSize: SizeConfig.res(5),
                      fontWeight: FontWeight.w800,
                      color: desgColor)),
            ),
            SizedBox(width: SizeConfig.sw(0.016)),

            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.staff.name,
                      style: TextStyle(
                          fontSize: SizeConfig.res(4.5),
                          fontWeight: FontWeight.w800,
                          color: _textDark)),
                  SizedBox(height: SizeConfig.sh(0.005)),
                  Row(
                    children: [
                      _badge(
                        widget.staff.designation.capitalizeFirst ?? '',
                        desgColor,
                      ),
                      SizedBox(width: SizeConfig.sw(0.006)),
                      _badge(
                        widget.staff.salaryMode.capitalizeFirst ?? '',
                        _primary,
                      ),
                      SizedBox(width: SizeConfig.sw(0.006)),
                      _activeDot(widget.staff.isActive),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.008)),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: SizeConfig.res(3.2), color: _textMid),
                      SizedBox(width: SizeConfig.sw(0.004)),
                      Text('+977-${widget.staff.phone}',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.2), color: _textMid)),
                      if (widget.staff.email != null &&
                          widget.staff.email!.isNotEmpty) ...[
                        SizedBox(width: SizeConfig.sw(0.014)),
                        Icon(Icons.email_outlined,
                            size: SizeConfig.res(3.2), color: _textMid),
                        SizedBox(width: SizeConfig.sw(0.004)),
                        Text(widget.staff.email!,
                            style: TextStyle(
                                fontSize: SizeConfig.res(3.2), color: _textMid)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isDaily) ...[
                  _actionBtn(
                    label: tracker != null ? 'Update Salary' : 'Set Salary',
                    icon: Icons.account_balance_wallet_outlined,
                    color: _primary,
                    onPressed: () => _openSalaryDialog(widget.staff.id!, tracker),
                  ),
                  SizedBox(height: SizeConfig.sh(0.008)),
                  if (tracker != null)
                    _actionBtn(
                      label: 'Pay Salary',
                      icon: Icons.payments_outlined,
                      color: _success,
                      onPressed: () => _openTransactionDialogUnified(
                          staffId: widget.staff.id!),
                    ),
                ],
                if (isDaily)
                  _actionBtn(
                    label: 'Pay Wage',
                    icon: Icons.payments_outlined,
                    color: _success,
                    onPressed: () =>
                        _openTransactionDialogUnified(staffId: widget.staff.id!),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.011)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4), color: color),
            SizedBox(width: SizeConfig.sw(0.006)),
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

  // ── Salary summary ─────────────────────────────────────────────────────────
  Widget _buildSalarySummary(Map<String, dynamic> tracker) {
    final isPaid = tracker['status'] == 'paid';
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.account_balance_wallet_outlined, 'Salary Summary'),
          SizedBox(height: SizeConfig.sh(0.016)),
          Row(
            children: [
              _salaryTile(
                Icons.attach_money,
                'Total Salary',
                tracker['total_salary'].toString(),
                _primary,
              ),
              _vDivider(),
              _salaryTile(
                Icons.check_circle_outline,
                'Paid Amount',
                tracker['paid_amount'].toString(),
                _success,
              ),
              _vDivider(),
              _salaryTile(
                Icons.pending_outlined,
                'Remaining',
                tracker['remaining_amount'].toString(),
                _warning,
              ),
              _vDivider(),
              _salaryStatusTile(tracker['status'], isPaid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salaryTile(IconData icon, String label, String value, Color color) {
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
                  style:
                      TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
              SizedBox(height: SizeConfig.sh(0.003)),
              Text('Rs. $value',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.6),
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salaryStatusTile(String status, bool isPaid) {
    final color = isPaid ? _success : _danger;
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2.2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline_rounded,
                size: SizeConfig.res(4.5), color: color),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status',
                  style:
                      TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
              SizedBox(height: SizeConfig.sh(0.003)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.008),
                    vertical: SizeConfig.sh(0.004)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(status.capitalizeFirst ?? status,
                    style: TextStyle(
                        fontSize: SizeConfig.res(3),
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Transaction list ───────────────────────────────────────────────────────
  Widget _buildTransactionList() {
    return Obx(() {
      final transactions = controller.transactions
          .where((tx) => tx['staff'] == widget.staff.id)
          .toList();

      if (transactions.isEmpty) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: SizeConfig.res(16), color: _border),
                SizedBox(height: SizeConfig.sh(0.012)),
                Text('No transactions yet',
                    style: TextStyle(
                        fontSize: SizeConfig.res(4), color: _textMid)),
              ],
            ),
          ),
        );
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.04),
                  vertical: SizeConfig.sh(0.008)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardTitle(Icons.receipt_outlined, 'Transactions'),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005)),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${transactions.length} records',
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.2),
                            fontWeight: FontWeight.w600,
                            color: _primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.04),
                    vertical: SizeConfig.sh(0.004)),
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final tx = transactions[i];
                  final isCash = tx['payment_mode'] == 'cash';
                  final modeColor = isCash ? _success : _info;

                  return Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.sh(0.01)),
                    child: Slidable(
                      key: ValueKey(tx['id']),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.28,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _openTransactionDialogUnified(
                              staffId: widget.staff.id!,
                              tx: tx,
                            ),
                            backgroundColor: _info,
                            foregroundColor: _surface,
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12)),
                          ),
                          SlidableAction(
                            onPressed: (_) => ConfirmDialog.show(
                              context,
                              title: 'Confirm Deletion',
                              message:
                                  'Are you sure you want to delete this transaction?',
                              onConfirm: () async {
                                await controller.deleteSalaryTransaction(
                                    tx['id'], widget.staff.id!);
                                await controller
                                    .refreshStaffData(widget.staff.id!);
                                DesktopToast.show(
                                    'Transaction deleted successfully',
                                    backgroundColor: _success);
                              },
                            ),
                            backgroundColor: _danger,
                            foregroundColor: _surface,
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12)),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.res(3.5)),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                          boxShadow: const [
                            BoxShadow(
                                color: _shadow, blurRadius: 4, offset: Offset(0, 1))
                          ],
                        ),
                        child: Row(
                          children: [
                            // mode icon
                            Container(
                              padding: EdgeInsets.all(SizeConfig.res(2.5)),
                              decoration: BoxDecoration(
                                color: modeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isCash
                                    ? Icons.payments_outlined
                                    : Icons.account_balance_outlined,
                                color: modeColor,
                                size: SizeConfig.res(5),
                              ),
                            ),
                            SizedBox(width: SizeConfig.sw(0.012)),

                            // date + note
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_outlined,
                                          size: SizeConfig.res(3.2),
                                          color: _textMid),
                                      SizedBox(width: SizeConfig.sw(0.004)),
                                      Text(tx['payment_date'],
                                          style: TextStyle(
                                              fontSize: SizeConfig.res(3.4),
                                              fontWeight: FontWeight.w700,
                                              color: _textDark)),
                                    ],
                                  ),
                                  if (tx['note'] != null &&
                                      tx['note'].toString().isNotEmpty) ...[
                                    SizedBox(height: SizeConfig.sh(0.004)),
                                    Row(
                                      children: [
                                        Icon(Icons.notes_outlined,
                                            size: SizeConfig.res(3.2),
                                            color: _textMid),
                                        SizedBox(width: SizeConfig.sw(0.004)),
                                        Expanded(
                                          child: Text(tx['note'],
                                              style: TextStyle(
                                                  fontSize: SizeConfig.res(3),
                                                  color: _textMid),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // amount + mode badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rs. ${tx['amount']}',
                                    style: TextStyle(
                                        fontSize: SizeConfig.res(4),
                                        fontWeight: FontWeight.w800,
                                        color: _success)),
                                SizedBox(height: SizeConfig.sh(0.004)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.sw(0.008),
                                      vertical: SizeConfig.sh(0.004)),
                                  decoration: BoxDecoration(
                                    color: modeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: modeColor.withOpacity(0.25)),
                                  ),
                                  child: Text(
                                    tx['payment_mode'].toString().capitalizeFirst ?? '',
                                    style: TextStyle(
                                        fontSize: SizeConfig.res(2.8),
                                        fontWeight: FontWeight.w600,
                                        color: modeColor),
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
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
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

  Widget _vDivider() {
    return Container(
      width: 1,
      height: SizeConfig.sh(0.05),
      color: _border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _activeDot(bool isActive) {
    final color = isActive ? _success : _danger;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.007), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeConfig.res(2.5),
            height: SizeConfig.res(2.5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: SizeConfig.sw(0.004)),
          Text(isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  fontSize: SizeConfig.res(2.8),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Salary dialog ──────────────────────────────────────────────────────────
  void _openSalaryDialog(int staffId, Map<String, dynamic>? tracker) {
    final totalCtrl = TextEditingController(
        text: tracker?['total_salary']?.toString() ?? '');

    Get.dialog(
      CustomFormDialog(
        title: tracker != null ? 'Update Salary' : 'Set Salary',
        width: 0.3,
        height: 0.35,
        content: _dialogField(totalCtrl, 'Total Salary', Icons.attach_money,
            keyboardType: TextInputType.number),
        onSave: () async {
          Navigator.of(Get.context!, rootNavigator: true).pop();
          controller.totalSalaryController.text = totalCtrl.text;
          if (tracker != null) {
            await controller.updateSalaryTracker(tracker['id'], staffId);
            DesktopToast.show('Salary updated successfully',
                backgroundColor: _success);
          } else {
            await controller.createSalaryTracker(staffId);
            DesktopToast.show('Salary created successfully',
                backgroundColor: _success);
          }
        },
      ),
    );
  }

  // ── Transaction dialog ─────────────────────────────────────────────────────
  void _openTransactionDialogUnified({
    required int staffId,
    Map<String, dynamic>? tx,
  }) {
    final selectedDate = Rxn<DateTime>(
        tx != null ? DateTime.parse(tx['payment_date']) : DateTime.now());
    final amountCtrl =
        TextEditingController(text: tx?['amount']?.toString() ?? '');
    final noteCtrl = TextEditingController(text: tx?['note'] ?? '');
    String paymentMode = tx?['payment_mode'] ?? 'cash';
    Map<String, dynamic>? tracker =
        controller.getNextSalaryTracker(staffId);

    Get.dialog(
      CustomFormDialog(
        title: tx == null ? 'Add Salary Transaction' : 'Edit Transaction',
        width: 0.35,
        height: 0.6,
        content: Column(
          children: [
            CommonDatePicker(
              label: 'Transaction Date',
              selectedDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
            SizedBox(height: SizeConfig.sh(0.012)),
            _dialogField(amountCtrl, 'Amount', Icons.payments_outlined,
                keyboardType: TextInputType.number),
            SizedBox(height: SizeConfig.sh(0.012)),
            DropdownButtonFormField<String>(
              value: paymentMode,
              style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
              decoration: InputDecoration(
                labelText: 'Payment Mode',
                labelStyle:
                    TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                    size: SizeConfig.res(4.5), color: _primary),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border)),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'online', child: Text('Online')),
              ],
              onChanged: (v) { if (v != null) paymentMode = v; },
            ),
            SizedBox(height: SizeConfig.sh(0.012)),
            _dialogField(noteCtrl, 'Note', Icons.notes_outlined),
          ],
        ),
        onSave: () async {
          Navigator.of(context, rootNavigator: true).pop();

          if (widget.staff.salaryMode != 'daily' && tracker == null) {
            await controller.createSalaryTracker(staffId);
            await controller.fetchSalaryTrackers(staffId);
            tracker = controller.salaryTrackers
                .firstWhereOrNull((t) => t['staff'] == staffId);
          }

          final payload = {
            'staff': staffId,
            'amount': double.parse(amountCtrl.text),
            'payment_mode': paymentMode,
            'note': noteCtrl.text,
            'transaction_type': widget.staff.salaryMode == 'daily'
                ? 'daily_salary'
                : 'monthly_salary',
            'salary_tracker': tracker?['id'],
            if (tx == null)
              'payment_date':
                  selectedDate.value!.toIso8601String().split('T')[0],
          };

          if (tx == null) {
            await controller.createSalaryTransaction(payload, staffId);
            DesktopToast.show('Transaction added successfully',
                backgroundColor: _success);
          } else {
            await controller.updateSalaryTransaction(tx['id'], payload, staffId);
            DesktopToast.show('Transaction updated successfully',
                backgroundColor: _success);
          }

          await controller.fetchSalaryTrackers(staffId);
          await controller.fetchTransactions(staffId);
        },
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
        prefixIcon:
            Icon(icon, size: SizeConfig.res(4.5), color: _primary),
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