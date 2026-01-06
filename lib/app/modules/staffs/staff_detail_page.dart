import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.sw(0.03),
                vertical: SizeConfig.sh(0.01),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: SizeConfig.res(10)),
                onPressed: () => Get.offAndToNamed(AppRoutes.navigation),
              ),
            ),
            _buildProfileCard(),
            _buildTransactionList(),
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
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.sw(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: SizeConfig.sw(0.05),
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.staff.name.isNotEmpty
                          ? widget.staff.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: SizeConfig.sw(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.staff.name,
                            style: TextStyle(
                                fontSize: SizeConfig.sw(0.04),
                                fontWeight: FontWeight.bold)),
                        Text(widget.staff.designation.toUpperCase(),
                            style: TextStyle(
                                fontSize: SizeConfig.sw(0.035),
                                color: Colors.grey)),
                        SizedBox(height: SizeConfig.sh(0.01)),
                        Text("Email: ${widget.staff.email}"),
                        Text("Phone: ${widget.staff.phone}"),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (widget.staff.salaryMode != 'daily') ...[
                        if (tracker != null) ...[
                          ElevatedButton(
                            onPressed: () =>
                                _openSalaryDialog(widget.staff.id!, tracker),
                            child: const Text("Update Salary"),
                          ),
                          SizedBox(height: SizeConfig.sh(0.01)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () =>
                                _openTransactionDialog(widget.staff.id!),
                            child: const Text("Pay Salary"),
                          ),
                        ] else
                          ElevatedButton(
                            onPressed: () =>
                                _openSalaryDialog(widget.staff.id!, null),
                            child: const Text("Set Salary"),
                          ),
                      ],
                      if (widget.staff.salaryMode == 'daily') ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () =>
                              _openTransactionDialog(widget.staff.id!),
                          child: const Text("Pay Salary"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (tracker != null && widget.staff.salaryMode != 'daily') ...[
                Divider(),
                Text("Total Salary: ${tracker['total_salary']}"),
                Text("Paid Amount: ${tracker['paid_amount']}"),
                Text("Remaining: ${tracker['remaining_amount']}"),
                Text("Status: ${tracker['status']}"),
              ]
            ],
          ),
        ),
      );
    });
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
                horizontal: SizeConfig.sw(0.03),
                vertical: SizeConfig.sh(0.01),
              ),
              child: Text(
                "Transactions",
                style: TextStyle(
                  fontSize: SizeConfig.sw(0.045),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(SizeConfig.sw(0.03)),
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final tx = transactions[i];
                  return Slidable(
                    key: ValueKey(tx['id']),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _editTransaction(tx),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (_) => _deleteTransaction(tx['id']),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.only(bottom: SizeConfig.sh(0.015)),
                      child: ListTile(
                        title: Text("Amount: ${tx['amount']}"),
                        subtitle: Text("Date: ${tx['payment_date']}"),
                        trailing: Text(tx['payment_mode']),
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

  // ---------------- Salary Dialog ----------------
  void _openSalaryDialog(int staffId, Map<String, dynamic>? tracker) {
    final totalCtrl =
        TextEditingController(text: tracker?['total_salary']?.toString() ?? '');
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().split('T')[0]);
    final modeCtrl = TextEditingController(text: 'cash');

    Get.dialog(CustomFormDialog(
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
          const SizedBox(height: 10),
          TextField(
            controller: dateCtrl,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Payment Date"),
          ),
        ],
      ),
      onSave: () async {
        controller.totalSalaryController.text = totalCtrl.text;
        controller.paymentDateController.text = dateCtrl.text;
        controller.paymentModeController.text = modeCtrl.text;

        if (tracker != null) {
          await controller.updateSalaryTracker(tracker['id'], staffId);
        } else {
          await controller.createSalaryTracker(staffId);
        }

        Navigator.of(context, rootNavigator: true).pop();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.closeAllSnackbars();
          Get.snackbar(
            "Success",
            "Salary saved successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      },
    ));
  }

  // ---------------- Transaction Dialog ----------------
  void _openTransactionDialog(int staffId) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String paymentMode = 'cash';

    Map<String, dynamic>? tracker = controller.salaryTrackers
        .firstWhereOrNull((t) => t['staff'] == staffId);

    Get.dialog(CustomFormDialog(
      title: "Add Salary Transaction",
      width: 0.45,
      height: 0.5,
      content: Column(
        children: [
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(labelText: "Note"),
          ),
        ],
      ),
      onSave: () async {
        Navigator.of(context, rootNavigator: true).pop();

        if (widget.staff.salaryMode != 'daily' && tracker == null) {
          await controller.createSalaryTracker(staffId);
          tracker = controller.salaryTrackers
              .firstWhereOrNull((t) => t['staff'] == staffId);
        }

        await controller.createSalaryTransaction({
          "staff": staffId,
          "amount": double.parse(amountCtrl.text),
          "payment_mode": paymentMode,
          "payment_date": DateTime.now().toIso8601String().split('T')[0],
          "transaction_type": widget.staff.salaryMode == 'daily'
              ? "daily_salary"
              : "monthly_salary",
          "note": noteCtrl.text,
          "salary_tracker": tracker != null ? tracker!['id'] : null,
        }, staffId);

        await controller.fetchTransactions(staffId);

        // Trigger dashboard chart refresh
        globalController.triggerRefresh(DashboardRefreshType.all);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Success",
            "Salary transaction added",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      },
    ));
  }

  // ---------------- Edit Transaction ----------------
  void _editTransaction(Map<String, dynamic> tx) {
    final amountCtrl = TextEditingController(text: tx['amount'].toString());
    final noteCtrl = TextEditingController(text: tx['note']);
    String paymentMode = tx['payment_mode'];

    final staffId = tx['staff'];
    Map<String, dynamic>? tracker = controller.salaryTrackers
        .firstWhereOrNull((t) => t['staff'] == staffId);

    Get.dialog(CustomFormDialog(
      title: "Edit Transaction",
      width: 0.45,
      height: 0.5,
      content: Column(
        children: [
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(labelText: "Note"),
          ),
        ],
      ),
      onSave: () async {
        Navigator.of(context, rootNavigator: true).pop();

        // 1️⃣ Update salary transaction
        await controller.updateSalaryTransaction(
          tx['id'],
          {
            "staff": staffId,
            "amount": double.parse(amountCtrl.text),
            "payment_mode": paymentMode,
            "note": noteCtrl.text,
            "transaction_type": widget.staff.salaryMode == 'daily'
                ? "daily_salary"
                : "monthly_salary",
            "salary_tracker": tracker != null ? tracker['id'] : null,
          },
          staffId,
        );

        // 3️⃣ Refresh transactions & charts
        await controller.fetchTransactions(staffId);
        // await expenseController.fetchExpenses();
        globalController.triggerRefresh(DashboardRefreshType.all);

        // 4️⃣ Success message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Success",
            "Transaction updated successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
      },
    ));
  }

  // ---------------- Delete Transaction ----------------
  void _deleteTransaction(int txId) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: const Text("Confirm Delete"),
        content:
            const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteSalaryTransaction(txId, widget.staff.id!);

      // Trigger dashboard chart refresh
      globalController.triggerRefresh(DashboardRefreshType.all);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Deleted",
          "Transaction deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }
  }
}
