import 'package:dio/dio.dart';
import '../models/expense_model.dart';
import 'api_service.dart';

class ExpenseService {
  final Dio _dio = ApiService.dio;

  Future<List<ExpenseModel>> getExpenses() async {
    final res = await _dio.get("/expenses/");
    final data = res.data;
    if (data != null && data['results'] != null && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => ExpenseModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final res = await _dio.post("/expenses/", data: expense.toJson());
    return ExpenseModel.fromJson(res.data);
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    if (expense.isSalaryExpense) {
      throw Exception("Salary expense cannot be edited");
    }

    final res = await _dio.put(
      "/expenses/${expense.id}/",
      data: expense.toJson(),
    );
    return ExpenseModel.fromJson(res.data);
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    if (expense.isSalaryExpense) {
      throw Exception("Salary expense cannot be deleted");
    }

    await _dio.delete("/expenses/${expense.id}/");
  }
}
