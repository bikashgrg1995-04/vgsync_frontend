import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepository;

  ExpenseController({required this.expenseRepository});

  /* ================= STATE ================= */

  final globalController = Get.find<GlobalController>();

  final expenses = <ExpenseModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final selectedDate = Rxn<DateTime>();
  final selectedExpenseType = 'All'.obs;
  final searchQuery = ''.obs;

  /* ================= FORM CONTROLLERS ================= */

  final titleCtrl = TextEditingController();
  final expenseTypeCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final paymentModeCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final spentByCtrl = TextEditingController();
  final expenseDateCtrl = TextEditingController();

  /* ================= LIFECYCLE ================= */

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
    setToday();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    expenseTypeCtrl.dispose();
    amountCtrl.dispose();
    paymentModeCtrl.dispose();
    noteCtrl.dispose();
    spentByCtrl.dispose();
    expenseDateCtrl.dispose();
    super.onClose();
  }

  /* ================= QUICK DATE ================= */

  void setToday() {
    selectedDate.value = DateTime.now();
  }

  void setYesterday() {
    selectedDate.value = DateTime.now().subtract(const Duration(days: 1));
  }

  void clearDateFilter() {
    selectedDate.value = null;
  }

  /* ================= FORM ================= */

  void clearForm() {
    titleCtrl.clear();
    expenseTypeCtrl.clear();
    amountCtrl.clear();
    paymentModeCtrl.clear();
    noteCtrl.clear();
    spentByCtrl.clear();
    expenseDateCtrl.clear();
  }

  void fillForm(ExpenseModel e) {
    titleCtrl.text = e.title;
    expenseTypeCtrl.text = e.expenseType;
    amountCtrl.text = e.amount.toString();
    paymentModeCtrl.text = e.paymentMode;
    noteCtrl.text = e.note ?? '';
    spentByCtrl.text = e.spentBy?.toString() ?? '';
    expenseDateCtrl.text = _formatDate(e.expenseDate);
  }

  /* ================= FETCH ================= */

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      expenses.assignAll(await expenseRepository.getExpenses());
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= CREATE ================= */

  Future<void> addExpense() async {
    try {
      isLoading.value = true;

      final expense = ExpenseModel(
        id: 0,
        title: titleCtrl.text.trim(),
        expenseType: expenseTypeCtrl.text,
        amount: double.tryParse(amountCtrl.text) ?? 0,
        paymentMode: paymentModeCtrl.text,
        note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        spentBy: int.tryParse(spentByCtrl.text),
        expenseDate: DateTime.parse(expenseDateCtrl.text),
        createdAt: DateTime.now(),
      );

      final result = await expenseRepository.create(expense);
      expenses.add(result);
      clearForm();
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= UPDATE ================= */

  Future<void> updateExpense(ExpenseModel old) async {
    if (!old.isEditable) {
      throw Exception('Salary expense cannot be edited');
    }

    try {
      isLoading.value = true;

      final updated = old.copyWith(
        title: titleCtrl.text.trim(),
        expenseType: expenseTypeCtrl.text,
        amount: double.tryParse(amountCtrl.text) ?? 0,
        paymentMode: paymentModeCtrl.text,
        note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        spentBy: int.tryParse(spentByCtrl.text),
        expenseDate: DateTime.parse(expenseDateCtrl.text),
      );

      final result = await expenseRepository.update(updated);

      final index = expenses.indexWhere((e) => e.id == result.id);
      if (index != -1) {
        expenses[index] = result;
        expenses.refresh();
      }

      clearForm();
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= DELETE ================= */

  Future<void> deleteExpense(ExpenseModel expense) async {
    if (!expense.isEditable) {
      throw Exception('Salary expense cannot be deleted');
    }

    try {
      isLoading.value = true;
      await expenseRepository.delete(expense);
      expenses.removeWhere((e) => e.id == expense.id);
      globalController.triggerRefresh(DashboardRefreshType.charts);
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= FILTER ================= */

  List<ExpenseModel> get filteredExpenses {
    return expenses.where((e) {
      final matchSearch = searchQuery.value.isEmpty ||
          e.title.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchType = selectedExpenseType.value == 'All' ||
          e.expenseType == selectedExpenseType.value;

      final matchDate = selectedDate.value == null ||
          _isSameDate(e.expenseDate, selectedDate.value!);

      return matchSearch && matchType && matchDate;
    }).toList();
  }

  /* ================= DAILY SUMMARY ================= */

  double get totalAmount => filteredExpenses.fold(0.0, (s, e) => s + e.amount);

  double get cashTotal => filteredExpenses
      .where((e) => e.paymentMode == 'cash')
      .fold(0.0, (s, e) => s + e.amount);

  double get onlineTotal => filteredExpenses
      .where((e) => e.paymentMode == 'online')
      .fold(0.0, (s, e) => s + e.amount);

  /* ================= HELPERS ================= */

  bool canEdit(ExpenseModel e) => e.isEditable;

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
