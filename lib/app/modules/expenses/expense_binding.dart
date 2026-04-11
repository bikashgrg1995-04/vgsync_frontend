import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';
import 'package:vgsync_frontend/app/data/services/expense_service.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy inject ExpenseService
    Get.lazyPut<ExpenseService>(() => ExpenseService());

    // Lazy inject ExpenseRepository with the service
    Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepository(expenseService: Get.find<ExpenseService>()));

    // Lazy inject ExpenseController with the repository
    Get.lazyPut<ExpenseController>(() =>
        ExpenseController(expenseRepository: Get.find<ExpenseRepository>()));
  }
}
