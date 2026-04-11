import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/staff_repository.dart';
import 'package:vgsync_frontend/app/data/services/expense_service.dart';
import 'package:vgsync_frontend/app/data/services/staff_service.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy inject ExpenseService
    Get.lazyPut<StaffService>(() => StaffService());

    // Lazy inject ExpenseRepository with the service
    Get.lazyPut<StaffRepository>(
        () => StaffRepository(staffService: Get.find<StaffService>()));

    // Lazy inject ExpenseController with the repository
    Get.lazyPut<StaffController>(
        () => StaffController(staffRepository: Get.find<StaffRepository>()));

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
