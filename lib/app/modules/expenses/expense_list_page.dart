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

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final ExpenseController controller =
      Get.put(ExpenseController(expenseRepository: Get.find()));
  final globalController = Get.find<GlobalController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            _topActions(),
            SizedBox(height: SizeConfig.sh(0.02)),
            _filtersRow(),
            _buildSummary(),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(child: _buildExpenseList()),
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

  /* ================= TOP ACTIONS ================= */

  Widget _topActions() {
    return Row(
      children: [
        SizedBox(
          width: SizeConfig.sw(0.45),
          child: TextField(
            controller: controller.searchController,
            onChanged: (v) => controller.searchQuery.value = v,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search expenses...',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(width: SizeConfig.sw(0.02)),
        actionButton(
          label: 'Refresh',
          icon: Icons.refresh,
          onPressed: controller.setDefaultFilters,
        ),
      ],
    );
  }

  Widget _filtersRow() {
    return SizedBox(
      height: SizeConfig.sh(0.15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3, // Date = bigger
            child: CommonDatePicker(
              label: 'Date Filter',
              selectedDate: controller.selectedDate,
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            flex: 2,
            child: _buildTypeFilter(),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            flex: 2,
            child: _buildPaymentFilter(),
          ),
        ],
      ),
    );
  }

  /* ================= TYPE FILTER ================= */
  Widget _buildTypeFilter() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expense Type Filter",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: controller.selectedExpenseType.value,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Salary', child: Text('Salary')),
              DropdownMenuItem(
                  value: 'Operational', child: Text('Operational')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) {
              controller.selectedExpenseType.value = v ?? 'All';
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    });
  }

/* ================= PAYMENT FILTER ================= */
  Widget _buildPaymentFilter() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Mode Filter",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: controller.selectedPaymentMode.value,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'Online', child: Text('Online')),
            ],
            onChanged: (v) {
              controller.selectedPaymentMode.value = v ?? 'All';
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    });
  }

  /* ================= SUMMARY ================= */

  Widget _buildSummary() {
    return Obx(() {
      final list = controller.filteredExpenses;

      final total = list.fold<double>(0, (sum, e) => sum + e.amount);
      final cash = list
          .where((e) => e.paymentMode == 'cash')
          .fold<double>(0, (s, e) => s + e.amount);
      final online = list
          .where((e) => e.paymentMode == 'online')
          .fold<double>(0, (s, e) => s + e.amount);

      return Row(
        children: [
          _summaryCard('Total', total, Colors.blue),
          _summaryCard('Cash', cash, Colors.green),
          _summaryCard('Online', online, Colors.orange),
        ],
      );
    });
  }

  Widget _summaryCard(String title, double value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      color: color,
                      fontSize: SizeConfig.res(5),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: SizeConfig.sh(0.01)),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.res(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/* ================= LIST ================= */

  Widget _buildExpenseList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Reverse the list so last expense appears first
      final list = controller.filteredExpenses.reversed.toList();

      if (list.isEmpty) {
        return const Center(child: Text('No expenses found'));
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => _expenseTile(list[i]),
      );
    });
  }

  Widget _expenseTile(ExpenseModel expense) {
    final editable = expense.isEditable;

    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: editable
          ? ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  icon: Icons.edit,
                  backgroundColor: Colors.orange,
                  onPressed: (_) => openExpenseDialog(expense),
                ),
                SlidableAction(
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  onPressed: (_) => controller.deleteExpense(expense),
                ),
              ],
            )
          : null,
      child: Card(
        child: ListTile(
          title: Text(expense.title),
          subtitle: Text(
            '${expense.expenseType.toUpperCase()} • ${expense.paymentMode}\n'
            '${expense.expenseDate.toIso8601String().split('T').first}',
          ),
          trailing: Text(
            expense.amount.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /* ================= FORM ================= */

  void openExpenseDialog([ExpenseModel? expense]) {
    final isEdit = expense != null;

    if (isEdit) {
      controller.fillForm(expense);
    } else {
      controller.clearForm();
      controller.saleDate.value = DateTime.now(); // default today
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Expense' : 'Add Expense',
        isEditMode: isEdit,
        content: _expenseForm(),
        onSave: () async {
          if (isEdit) {
            await controller.updateExpense(expense);
            Get.back(closeOverlays: true);
            DesktopToast.show(
              'Expense updated successfully',
              backgroundColor: Colors.greenAccent,
            );
          } else {
            await controller.addExpense();
            Get.back(closeOverlays: true);
            DesktopToast.show(
              'Expense added successfully',
              backgroundColor: Colors.greenAccent,
            );
          }
        },
        height: 0.65,
        width: 0.25,
      ),
    );
  }

  Widget _expenseForm() {
    return Column(
      children: [
        // <-- Sale/Expense Date Picker
        CommonDatePicker(
          label: 'Expense Date',
          selectedDate: controller.saleDate,
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        buildTextField(
          controller.titleCtrl,
          'Title',
          Icons.title,
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        commonDropdown(
          controller.paymentModeRx,
          'Payment Mode',
          const ['Cash', 'Online'],
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        commonDropdown(
          controller.expenseTypeRx,
          'Expense Type',
          const ['All', 'Salary', 'Operational', 'Other'],
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        buildTextField(
          controller.amountCtrl,
          'Amount',
          Icons.currency_rupee,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        buildTextField(
          controller.noteCtrl,
          'Note',
          Icons.note,
        ),
      ],
    );
  }
}
