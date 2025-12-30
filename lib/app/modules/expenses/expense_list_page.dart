import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
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

  final searchController = TextEditingController();

  /// all | salary | operational | other
  String selectedExpenseType = 'all';

  /// single date filter
  DateTime? selectedDate;

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
            const SizedBox(height: 10),
            _buildSearch(),
            const SizedBox(height: 10),
            _filtersRow(),
            const SizedBox(height: 10),
            _buildSummary(),
            const SizedBox(height: 10),
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
        const Text(
          'Expenses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDate = null;
                selectedExpenseType = 'all';
                searchController.clear();
              });
              controller.searchQuery.value = '';
              controller.fetchExpenses();
            },
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Refresh")
              ],
            ))
      ],
    );
  }

  /* ================= SEARCH ================= */

  Widget _buildSearch() {
    return TextField(
      controller: searchController,
      onChanged: (v) => controller.searchQuery.value = v,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search expenses...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /* ================= FILTER ROW ================= */

  Widget _filtersRow() {
    return SizedBox(
      height: SizeConfig.sh(0.15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _dateFilter()),
          const SizedBox(width: 8),
          Expanded(child: _buildTypeFilter()),
        ],
      ),
    );
  }

  /* ================= DATE FILTER ================= */

  Widget _dateFilter() {
    return Column(
      children: [
        Text(
          "Date Filter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
          child: Container(
            height: SizeConfig.sh(0.075),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  selectedDate == null
                      ? 'Select date'
                      : selectedDate!.toIso8601String().split('T').first,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /* ================= TYPE FILTER ================= */

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Expense Type Filter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        DropdownButtonFormField<String>(
          value: selectedExpenseType,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'salary', child: Text('Salary')),
            DropdownMenuItem(value: 'operational', child: Text('Operational')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => selectedExpenseType = v ?? 'all'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  /* ================= SUMMARY ================= */

  Widget _buildSummary() {
    return Obx(() {
      final list = _filteredList();

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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color)),
              const SizedBox(height: 4),
              Text(
                value.toStringAsFixed(2),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= FILTER LOGIC ================= */

  List<ExpenseModel> _filteredList() {
    return controller.filteredExpenses.where((e) {
      if (selectedExpenseType != 'all' &&
          e.expenseType != selectedExpenseType) {
        return false;
      }

      if (selectedDate != null && !e.isSameDate(selectedDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  /* ================= LIST ================= */

  Widget _buildExpenseList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = _filteredList();

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
      controller.expenseDateCtrl.text =
          DateTime.now().toIso8601String().split('T')[0];
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Expense' : 'Add Expense',
        isEditMode: isEdit,
        content: _expenseForm(),
        onSave: () async {
          if (isEdit) {
            await controller.updateExpense(expense);
            globalController.triggerRefresh(DashboardRefreshType.charts);
          } else {
            await controller.addExpense();
            globalController.triggerRefresh(DashboardRefreshType.charts);
          }
          Get.back();
        },
        height: 10,
        width: 10,
      ),
    );
  }

  Widget _expenseForm() {
    return Column(
      children: [
        _text(controller.titleCtrl, 'Title'),
        _dropdown(
            controller.paymentModeCtrl, 'Payment Mode', ['cash', 'online']),
        _dropdown(controller.expenseTypeCtrl, 'Expense Type',
            ['salary', 'operational', 'other']),
        _text(controller.amountCtrl, 'Amount', keyboard: TextInputType.number),
        _text(controller.noteCtrl, 'Note', maxLines: 2),
      ],
    );
  }

  Widget _text(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdown(TextEditingController c, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<String>(
        value: c.text.isEmpty ? null : c.text,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => c.text = v ?? '',
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
