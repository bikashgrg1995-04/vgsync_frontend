import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService expenseService;

  ExpenseRepository({required this.expenseService});

  Future<List<ExpenseModel>> getExpenses() => expenseService.getExpenses();
  Future<ExpenseModel> create(ExpenseModel expense) =>
      expenseService.createExpense(expense);
  Future<ExpenseModel> update(ExpenseModel expense) =>
      expenseService.updateExpense(expense);
  Future<void> delete(int id) => expenseService.deleteExpense(id);
}
