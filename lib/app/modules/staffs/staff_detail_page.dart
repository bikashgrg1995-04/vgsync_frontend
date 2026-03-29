// app/modules/staffs/staff_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../data/models/staff_model.dart';
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
  final globalController = Get.find<GlobalController>();

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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- BACK BUTTON ----------
            CommonBackButton(
              onTap: () => Get.offAndToNamed(AppRoutes.navigation),
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            _buildProfileCard(),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------- SALARY SUMMARY ----------
            Obx(() {
              final tracker = controller.salaryTrackers
                  .firstWhereOrNull((t) => t['staff'] == widget.staff.id);
              if (tracker != null && widget.staff.salaryMode != 'daily') {
                return _buildSalarySummary(tracker);
              }
              return const SizedBox();
            }),
            // ---------- TRANSACTION LIST ----------
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalarySummary(Map<String, dynamic>? tracker) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.04),
        vertical: SizeConfig.sh(0.01),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.01)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TITLE ----------
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  "Salary Summary",
                  style: TextStyle(
                    fontSize: SizeConfig.sw(0.016),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------- ROW 1 ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _salaryItem(
                  title: "Total Salary",
                  value: tracker!['total_salary'].toString(),
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
                _salaryItem(
                  title: "Paid Amount",
                  value: tracker['paid_amount'].toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _salaryItem(
                  title: "Remaining",
                  value: tracker['remaining_amount'].toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _salaryItem(
                  title: "Status",
                  value: tracker['status'],
                  icon: Icons.info,
                  color: tracker['status'] == 'paid' ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final tracker = controller.salaryTrackers
          .firstWhereOrNull((t) => t['staff'] == widget.staff.id);

      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.03),
          vertical: SizeConfig.sh(0.01),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.08),
            vertical: SizeConfig.sh(0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: SizeConfig.sw(0.03),
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.staff.name.isNotEmpty
                          ? widget.staff.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.res(10),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.staff.name,
                          style: TextStyle(
                              fontSize: SizeConfig.sw(0.025),
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.sw(0.015),
                            vertical: SizeConfig.sh(0.002),
                          ),
                          child: Text(
                            widget.staff.designation.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.sw(0.015),
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(height: SizeConfig.sh(0.01)),
                        Row(
                          children: [
                            Text("Email: ${widget.staff.email ?? 'N/A'}"),
                            SizedBox(width: SizeConfig.sw(0.03)),
                            Text("Phone: +977-${widget.staff.phone}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (widget.staff.salaryMode != 'daily') ...[
                        SizedBox(
                          width: SizeConfig.sw(0.15),
                          child: ElevatedButton(
                            onPressed: () =>
                                _openSalaryDialog(widget.staff.id!, tracker),
                            child: Text(
                                tracker != null ? "Update Salary" : "Set Salary"),
                          ),
                        ),
                        SizedBox(height: SizeConfig.sh(0.01)),
                        if (tracker != null)
                          SizedBox(
                            width: SizeConfig.sw(0.15),
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _openTransactionDialogUnified(
                                  staffId: widget.staff.id!),
                              child: const Text("Pay Salary"),
                            ),
                          ),
                      ],
                      if (widget.staff.salaryMode == 'daily')
                        SizedBox(
                          width: SizeConfig.sw(0.15),
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _openTransactionDialogUnified(
                                staffId: widget.staff.id!),
                            child: const Text("Pay Wage"),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _salaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      final transactions = controller.transactions
          .where((tx) => tx['staff'] == widget.staff.id)
          .toList();

      if (transactions.isEmpty) {
        return const Center(child: Text("No transactions yet"));
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.05),
                vertical: SizeConfig.sh(0.01),
              ),
              child: Text(
                "Transactions",
                style: TextStyle(
                  fontSize: SizeConfig.sw(0.015),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.06)),
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final tx = transactions[i];
                  return Slidable(
                    key: ValueKey(tx['id']),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _openTransactionDialogUnified(
                            staffId: widget.staff.id!,
                            tx: tx,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
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
                              await controller.refreshStaffData(widget.staff.id!);
                              DesktopToast.show(
                                'Transaction deleted successfully',
                                backgroundColor: Colors.greenAccent,
                              );
                            },
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.02)),
                      child: ListTile(
                        title: Text(
                          "Date: ${tx['payment_date']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Amount: ${tx['amount']}"),
                            Text("Note: ${tx['note'] ?? 'N/A'}"),
                          ],
                        ),
                        trailing: Text(
                          tx['payment_mode'].toString().capitalizeFirst!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tx['payment_mode'] == 'cash'
                                ? Colors.green
                                : Colors.blueAccent,
                            fontSize: SizeConfig.sw(0.016),
                          ),
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

  // ---------------- SALARY DIALOG ----------------
  void _openSalaryDialog(int staffId, Map<String, dynamic>? tracker) {
    final totalCtrl =
        TextEditingController(text: tracker?['total_salary']?.toString() ?? '');
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().split('T')[0]);
    final modeCtrl = TextEditingController(text: 'cash');

    Get.dialog(
      CustomFormDialog(
        title: tracker != null ? "Update Salary" : "Set Salary",
        width: 0.45,
        height: 0.5,
        content: Column(
          children: [
            TextField(
              controller: totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Salary"),
            ),
          ],
        ),
        onSave: () async {
          Navigator.of(Get.context!, rootNavigator: true).pop();
          controller.totalSalaryController.text = totalCtrl.text;
          controller.paymentDateController.text = dateCtrl.text;
          controller.paymentModeController.text = modeCtrl.text;

          if (tracker != null) {
            await controller.updateSalaryTracker(tracker['id'], staffId);
            DesktopToast.show(
              'Salary updated successfully',
              backgroundColor: Colors.greenAccent,
            );
          } else {
            await controller.createSalaryTracker(staffId);
            DesktopToast.show(
              'Salary created successfully',
              backgroundColor: Colors.greenAccent,
            );
          }
        },
      ),
    );
  }

  // ---------------- TRANSACTION DIALOG ----------------
  void _openTransactionDialogUnified({
  required int staffId,
  Map<String, dynamic>? tx,
}) {
  final Rxn<DateTime> selectedDate =
      Rxn<DateTime>(tx != null ? DateTime.parse(tx['payment_date']) : DateTime.now());

  final amountCtrl = TextEditingController(text: tx?['amount']?.toString() ?? '');
  final noteCtrl = TextEditingController(text: tx?['note'] ?? '');
  String paymentMode = tx?['payment_mode'] ?? 'cash';

  Map<String, dynamic>? tracker = controller.getNextSalaryTracker(staffId);

  Get.dialog(
    CustomFormDialog(
      title: tx == null ? "Add Salary Transaction" : "Edit Transaction",
      width: 0.45,
      height: 0.6,
      content: Column(
        children: [
          CommonDatePicker(
            label: "Transaction Date",
            selectedDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          DropdownButtonFormField<String>(
            value: paymentMode,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash')),
              DropdownMenuItem(value: 'online', child: Text('Online')),
            ],
            onChanged: (value) {
              if (value != null) paymentMode = value;
            },
            decoration: const InputDecoration(labelText: "Payment Mode"),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(labelText: "Note"),
          ),
        ],
      ),
      onSave: () async {
        Navigator.of(context, rootNavigator: true).pop();

        // -----------------------------
        // Ensure tracker exists for monthly salary
        // -----------------------------
        if (widget.staff.salaryMode != 'daily' && tracker == null) {
          await controller.createSalaryTracker(staffId);

          // REFRESH tracker after creation
          await controller.fetchSalaryTrackers(staffId);
          tracker = controller.salaryTrackers.firstWhereOrNull((t) => t['staff'] == staffId);
        }

        // -----------------------------
        // Prepare payload
        // -----------------------------
        final payload = {
          "staff": staffId,
          "amount": double.parse(amountCtrl.text),
          "payment_mode": paymentMode,
          "note": noteCtrl.text,
          "transaction_type": widget.staff.salaryMode == 'daily'
              ? "daily_salary"
              : "monthly_salary",
          "salary_tracker": tracker?['id'],
          if (tx == null)
            "payment_date": selectedDate.value!.toIso8601String().split('T')[0],
        };

        // -----------------------------
        // CREATE or UPDATE transaction
        // -----------------------------
        if (tx == null) {
          await controller.createSalaryTransaction(payload, staffId);
          DesktopToast.show(
            'Transaction added successfully',
            backgroundColor: Colors.greenAccent,
          );
        } else {
          await controller.updateSalaryTransaction(tx['id'], payload, staffId);
          DesktopToast.show(
            'Transaction updated successfully',
            backgroundColor: Colors.greenAccent,
          );
        }

        // -----------------------------
        // REFRESH tracker & transactions
        // -----------------------------
        await controller.fetchSalaryTrackers(staffId);
        await controller.fetchTransactions(staffId);
      },
    ),
  );
}



}
