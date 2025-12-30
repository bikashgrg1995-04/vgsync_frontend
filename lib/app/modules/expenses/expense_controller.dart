import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/expense_model.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepository;

  ExpenseController({required this.expenseRepository});

  var expenses = <ExpenseModel>[].obs;
  var isLoading = false.obs;

  // ---------------- Form Controllers ----------------
  final titleCtrl = TextEditingController();
  final expenseTypeCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final paymentModeCtrl = TextEditingController();
  final referenceTypeCtrl = TextEditingController();
  final referenceIdCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final spentByCtrl = TextEditingController();
  final expenseDateCtrl = TextEditingController();

  // ---------------- Helper Methods ----------------
  void clearForm() {
    titleCtrl.clear();
    expenseTypeCtrl.clear();
    amountCtrl.clear();
    paymentModeCtrl.clear();
    referenceTypeCtrl.clear();
    referenceIdCtrl.clear();
    noteCtrl.clear();
    spentByCtrl.clear();
    expenseDateCtrl.clear();
  }

  void fillForm(ExpenseModel expense) {
    titleCtrl.text = expense.title;
    expenseTypeCtrl.text = expense.expenseType;
    amountCtrl.text = expense.amount.toString();
    paymentModeCtrl.text = expense.paymentMode;
    referenceTypeCtrl.text = expense.referenceType ?? '';
    referenceIdCtrl.text = expense.referenceId?.toString() ?? '';
    noteCtrl.text = expense.note ?? '';
    spentByCtrl.text = expense.spentBy?.toString() ?? '';
    expenseDateCtrl.text = expense.expenseDate.toIso8601String().split('T')[0];
  }

  // ---------------- Fetch Expenses ----------------
  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      final result = await expenseRepository.getExpenses();
      expenses.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add Expense ----------------
  Future<void> addExpense() async {
    try {
      isLoading.value = true;
      final expense = ExpenseModel(
        id: 0, // backend will assign
        title: titleCtrl.text,
        expenseType: expenseTypeCtrl.text,
        amount: double.tryParse(amountCtrl.text) ?? 0,
        paymentMode: paymentModeCtrl.text,
        referenceType:
            referenceTypeCtrl.text.isEmpty ? null : referenceTypeCtrl.text,
        referenceId: int.tryParse(referenceIdCtrl.text),
        note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        spentBy: int.tryParse(spentByCtrl.text),
        expenseDate: DateTime.parse(expenseDateCtrl.text),
        createdAt: DateTime.now(),
      );
      final newExpense = await expenseRepository.create(expense);
      expenses.add(newExpense);
      Get.back();
      clearForm();
      Get.snackbar('Success', 'Expense added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Update Expense ----------------
  Future<void> updateExpense(ExpenseModel oldExpense) async {
    try {
      isLoading.value = true;
      final expense = ExpenseModel(
        id: oldExpense.id,
        title: titleCtrl.text,
        expenseType: expenseTypeCtrl.text,
        amount: double.tryParse(amountCtrl.text) ?? 0,
        paymentMode: paymentModeCtrl.text,
        referenceType:
            referenceTypeCtrl.text.isEmpty ? null : referenceTypeCtrl.text,
        referenceId: int.tryParse(referenceIdCtrl.text),
        note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
        spentBy: int.tryParse(spentByCtrl.text),
        expenseDate: DateTime.parse(expenseDateCtrl.text),
        createdAt: oldExpense.createdAt,
      );
      final updatedExpense = await expenseRepository.update(expense);
      final index = expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) expenses[index] = updatedExpense;
      Get.back();
      clearForm();
      Get.snackbar('Success', 'Expense updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Expense ----------------
  Future<void> deleteExpense(int id) async {
    try {
      isLoading.value = true;
      await expenseRepository.delete(id);
      expenses.removeWhere((e) => e.id == id);
      Get.snackbar('Success', 'Expense deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Search & Filter ----------------
  List<ExpenseModel> searchExpenses(String query) {
    final q = query.toLowerCase();
    return expenses.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.expenseType.toLowerCase().contains(q) ||
          e.paymentMode.toLowerCase().contains(q);
    }).toList();
  }

  List<ExpenseModel> filterExpenses(
      {String query = '', DateTime? start, DateTime? end}) {
    final q = query.toLowerCase();
    return expenses.where((e) {
      final matchesQuery = e.title.toLowerCase().contains(q) ||
          e.expenseType.toLowerCase().contains(q) ||
          e.paymentMode.toLowerCase().contains(q);
      final matchesStart = start == null || !e.expenseDate.isBefore(start);
      final matchesEnd = end == null || !e.expenseDate.isAfter(end);
      return matchesQuery && matchesStart && matchesEnd;
    }).toList();
  }
}
