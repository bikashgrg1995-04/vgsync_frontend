import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../wigdets/custom_form_dialog.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final ExpenseController controller =
      Get.put(ExpenseController(expenseRepository: Get.find()));
  final searchController = TextEditingController();
  String quickFilter = 'All'; // All, Daily, Monthly, Yearly

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchExpenses();
    });
  }

  DateTime getStartDate() {
    final now = DateTime.now();
    switch (quickFilter) {
      case 'Daily':
        return DateTime(now.year, now.month, now.day);
      case 'Monthly':
        return DateTime(now.year, now.month, 1);
      case 'Yearly':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(2000);
    }
  }

  DateTime getEndDate() => DateTime.now();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            // ---------------- Quick Filter Buttons ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Daily', 'Monthly', 'Yearly'].map((label) {
                final selected = quickFilter == label;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Colors.blue : Colors.grey[300],
                    foregroundColor: selected ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      quickFilter = label;
                    });
                  },
                  child: Text(label),
                );
              }).toList(),
            ),
            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Search & Refresh ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search expenses...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => controller.expenses.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                SizedBox(
                  width: SizeConfig.sw(0.12),
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchExpenses,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Expense List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filterExpenses(
                  query: searchController.text,
                  start: getStartDate(),
                  end: getEndDate(),
                );

                if (filtered.isEmpty) {
                  return const Center(child: Text('No expenses found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final expense = filtered[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(expense.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openExpenseDialog(expense),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.deleteExpense(expense.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.sw(0.01)),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(expense.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Type: ${expense.expenseType} | Amount: ${expense.amount.toStringAsFixed(2)}'),
                                Text(
                                    'Date: ${expense.expenseDate.toIso8601String().split('T')[0]} | Payment: ${expense.paymentMode}'),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openExpenseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  // ---------------- Add/Edit Dialog ----------------
  void openExpenseDialog([ExpenseModel? expense]) {
    final isEdit = expense != null;
    if (isEdit) {
      controller.fillForm(expense);
    } else {
      controller.clearForm();
      controller.expenseDateCtrl.text =
          DateTime.now().toIso8601String().split('T')[0];
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? "Edit Expense" : "Add Expense",
        isEditMode: isEdit,
        width: 0.3,
        height: 0.65,
        content: Column(
          children: [
            TextField(
              controller: controller.expenseDateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Expense Date'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.tryParse(controller.expenseDateCtrl.text) ??
                          DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.expenseDateCtrl.text =
                      picked.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: controller.paymentModeCtrl.text.isEmpty
                  ? null
                  : controller.paymentModeCtrl.text,
              items: ['cash', 'online']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => controller.paymentModeCtrl.text = val ?? '',
              decoration: const InputDecoration(labelText: 'Payment Mode'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: controller.expenseTypeCtrl.text.isEmpty
                  ? null
                  : controller.expenseTypeCtrl.text,
              items: ['Salary', 'Operational', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => controller.expenseTypeCtrl.text = val ?? '',
              decoration: const InputDecoration(labelText: 'Expense Type'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        onSave: () {
          if (isEdit) {
            controller.updateExpense(expense);
          } else {
            controller.addExpense();
          }
          Get.back();
        },
        onDelete: isEdit
            ? () {
                controller.deleteExpense(expense.id);
                Get.back();
              }
            : null,
      ),
      barrierDismissible: false,
    );
  }
}
