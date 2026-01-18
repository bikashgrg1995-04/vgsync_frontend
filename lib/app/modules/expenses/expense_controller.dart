import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepository;

  ExpenseController({required this.expenseRepository});

  /* ================= STATE ================= */

  final globalController = Get.find<GlobalController>();
  final dashboardController = Get.find<DashboardController>();

  final expenses = <ExpenseModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final searchController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  final selectedExpenseType = 'All'.obs;
  final searchQuery = ''.obs;
  final selectedPaymentMode = 'All'.obs;

  /* ================= FORM CONTROLLERS ================= */

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final spentByCtrl = TextEditingController();
  final saleDate = Rxn<DateTime>();

  // Dropdown reactive values
  final paymentModeRx = 'Cash'.obs;
  final expenseTypeRx = 'All'.obs;

  /* ================= LIFECYCLE ================= */

  @override
  void onInit() {
    super.onInit();
    setDefaultFilters();
    fetchExpenses();
    //setToday();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    spentByCtrl.dispose();
    super.onClose();
  }

  /* ================= FORM ================= */
  void clearForm() {
    titleCtrl.clear();
    amountCtrl.clear();
    noteCtrl.clear();
    spentByCtrl.clear();
    saleDate.value = DateTime.now(); // default today

    // Reset dropdowns to default values
    paymentModeRx.value = 'Cash';
    expenseTypeRx.value = 'Other';
  }

  void fillForm(ExpenseModel e) {
    titleCtrl.text = e.title;
    amountCtrl.text = e.amount.toString();
    noteCtrl.text = e.note ?? '';
    spentByCtrl.text = e.spentBy?.toString() ?? '';
    saleDate.value = e.expenseDate; // <-- old date

    // Set dropdowns
    paymentModeRx.value = e.paymentMode.isEmpty
        ? 'Cash'
        : e.paymentMode.toString().capitalizeFirst!.trim();
    expenseTypeRx.value = e.expenseType.isEmpty
        ? 'Other'
        : e.expenseType.toString().capitalizeFirst!.trim();
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

  Future<void> addExpense() async {
    try {
      isLoading.value = true;

      final expense = ExpenseModel(
        id: 0,
        title:
            titleCtrl.text.trim().isEmpty ? 'Untitled' : titleCtrl.text.trim(),
        expenseType: (expenseTypeRx.value.isEmpty
            ? 'other'
            : expenseTypeRx.value.toLowerCase()),
        amount: double.tryParse(amountCtrl.text) ?? 0,
        paymentMode: (paymentModeRx.value.isEmpty
            ? 'cash'
            : paymentModeRx.value.toLowerCase()),
        note: noteCtrl.text.isEmpty ? null : noteCtrl.text.trim(),
        spentBy:
            spentByCtrl.text.isEmpty ? null : int.tryParse(spentByCtrl.text),
        expenseDate: saleDate.value ?? DateTime.now(), // <-- use saleDate
        createdAt: DateTime.now(),
      );

      final result = await expenseRepository.create(expense);
      expenses.add(result);
      clearForm();
      await dashboardController.loadDashboardData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(ExpenseModel old) async {
    if (!old.isEditable) {
      throw Exception('Salary expense cannot be edited');
    }

    try {
      isLoading.value = true;

      final updated = old.copyWith(
        title:
            titleCtrl.text.trim().isEmpty ? old.title : titleCtrl.text.trim(),
        expenseType: (expenseTypeRx.value.isEmpty
            ? old.expenseType
            : expenseTypeRx.value.toLowerCase()),
        amount: double.tryParse(amountCtrl.text) ?? old.amount,
        paymentMode: (paymentModeRx.value.isEmpty
            ? old.paymentMode
            : paymentModeRx.value.toLowerCase()),
        note: noteCtrl.text.isEmpty ? old.note : noteCtrl.text.trim(),
        spentBy: spentByCtrl.text.isEmpty
            ? old.spentBy
            : int.tryParse(spentByCtrl.text),
        expenseDate: saleDate.value ?? DateTime.now(), // <-- use saleDate
      );

      final result = await expenseRepository.update(updated);

      final index = expenses.indexWhere((e) => e.id == result.id);
      if (index != -1) {
        expenses[index] = result;
        expenses.refresh();
      }

      clearForm();
      await dashboardController.loadDashboardData();
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= DELETE ================= */

  Future<void> deleteExpense(ExpenseModel expense) async {
    if (!expense.isEditable) {
      throw Exception('Salary expense cannot be deleted');
    }

    ConfirmDialog.show(
      Get.context!,
      title: 'Delete Expense',
      message: 'Are you sure you want to delete this expense?',
      onConfirm: () async {
        try {
          isLoading.value = true;
          await expenseRepository.delete(expense);
          expenses.removeWhere((e) => e.id == expense.id);
          globalController.triggerRefresh(DashboardRefreshType.all);
          Get.back(closeOverlays: true);
          DesktopToast.show('Expense deleted successfully',  backgroundColor: Colors.greenAccent,);
         
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  /* ================= FILTER ================= */

  List<ExpenseModel> get filteredExpenses {
    return expenses.where((e) {
      final matchSearch = searchQuery.value.isEmpty ||
          e.title.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchType = selectedExpenseType.value.toLowerCase() == 'all' ||
          e.expenseType.toLowerCase() ==
              selectedExpenseType.value.toLowerCase();

      final matchDate = selectedDate.value == null ||
          _isSameDate(e.expenseDate, selectedDate.value!);

      final matchPayment = selectedPaymentMode.value.toLowerCase() == 'all' ||
          e.paymentMode.toLowerCase() ==
              selectedPaymentMode.value.toLowerCase();

      return matchSearch && matchType && matchDate && matchPayment;
    }).toList();
  }

  void setDefaultFilters() {
    selectedDate.value = null;
    selectedExpenseType.value = 'All';
    searchQuery.value = '';
    searchController.clear();
    selectedPaymentMode.value = 'All';
  }

  /* ================= HELPERS ================= */

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
