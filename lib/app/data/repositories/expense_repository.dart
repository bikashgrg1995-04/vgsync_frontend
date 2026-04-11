import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService expenseService;

  ExpenseRepository({required this.expenseService});

  /// Fetch all expenses (filtering controller मा हुनेछ)
  Future<List<ExpenseModel>> getExpenses() {
    return expenseService.getExpenses();
  }

  /// Create manual expense
  Future<ExpenseModel> create(ExpenseModel expense) {
    return expenseService.createExpense(expense);
  }

  /// Update expense (salary expense guard service मा छ)
  Future<ExpenseModel> update(ExpenseModel expense) {
    return expenseService.updateExpense(expense);
  }

  /// Delete expense (salary expense guard service मा छ)
  Future<void> delete(ExpenseModel expense) {
    return expenseService.deleteExpense(expense);
  }
}
