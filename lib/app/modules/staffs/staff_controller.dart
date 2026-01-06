import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import '../../data/models/staff_model.dart';
import '../../data/repositories/staff_repository.dart';

class StaffController extends GetxController {
  final StaffRepository staffRepository;

  StaffController({required this.staffRepository});

  // ---------------- Reactive variables ----------------
  var staffs = <StaffModel>[].obs;
  var isLoading = false.obs;

  final ExpenseController expenseController = Get.find<ExpenseController>();

  // Selected staff's salary trackers & transactions
  var salaryTrackers = <Map<String, dynamic>>[].obs;
  var transactions = <Map<String, dynamic>>[].obs;

  // Controllers for add/edit staff
  final nameController = TextEditingController();
  final designationController = TextEditingController();
  final salaryModeController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final isActiveController = RxBool(true);

  // Salary Tracker Controllers
  final totalSalaryController = TextEditingController();
  final paymentDateController = TextEditingController();
  final paymentModeController = TextEditingController();
  final transactionNoteController = TextEditingController();
  final transactionAmountController = TextEditingController();

  // Date filter controllers
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchStaff(); // ✅ SAFE
  }

  // ---------------- Fetch Staff ----------------
  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getStaffs();
      staffs.assignAll(result);
    } catch (e) {
      //Get.snackbar('Error', 'Failed to fetch staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add Staff ----------------
  Future<StaffModel> addStaff({bool withSalaryTracker = false}) async {
    if (!_validateStaffInputs()) return Future.error("Validation failed");

    try {
      isLoading.value = true;
      final newStaff = StaffModel(
        name: nameController.text,
        designation: designationController.text,
        designationDisplay:
            designationController.text, // same as designation by default
        salaryMode: salaryModeController.text,
        salaryModeDisplay:
            salaryModeController.text, // same as salary mode by default
        phone: phoneController.text,
        email: emailController.text,
        isActive: isActiveController.value,
        joinedDate: DateTime.now(),
      );

      final added = await staffRepository.create(newStaff);
      staffs.add(added);

      clearControllers(); // Reset controllers after save
      return added;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStaff(StaffModel staff) async {
    if (!_validateStaffInputs()) return;

    try {
      isLoading.value = true;
      final updatedStaff = StaffModel(
        id: staff.id,
        name: nameController.text,
        designation: designationController.text,
        designationDisplay: designationController.text, // updated
        salaryMode: salaryModeController.text,
        salaryModeDisplay: salaryModeController.text, // updated
        phone: phoneController.text,
        email: emailController.text,
        isActive: isActiveController.value,
        joinedDate: staff.joinedDate,
      );

      final updated = await staffRepository.update(updatedStaff);
      final index = staffs.indexWhere((s) => s.id == updated.id);
      if (index != -1) staffs[index] = updated;

      clearControllers();
    } catch (e) {
      print('Failed to update staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Staff ----------------
  Future<void> deleteStaff(int id) async {
    try {
      isLoading.value = true;
      await staffRepository.delete(id);
      staffs.removeWhere((s) => s.id == id);
      // Get.snackbar('Success', 'Staff deleted successfully');
    } catch (e) {
      //   Get.snackbar('Error', 'Failed to delete staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Salary Tracker ----------------
  Future<void> createSalaryTracker(int staffId) async {
    if (!_validateSalaryInputs()) return;

    try {
      final trackerData = {
        "staff": staffId,
        "total_salary": double.tryParse(totalSalaryController.text) ?? 0,
        "payment_date": paymentDateController.text,
        "payment_mode": paymentModeController.text,
        "transaction_type": "salary",
      };

      await staffRepository.createSalaryTracker(trackerData);
      // Get.snackbar('Success', 'Salary Tracker created successfully');

      // Refresh list
      await fetchSalaryTrackers(staffId);

      clearControllers(); // Reset controllers after save
    } catch (e) {
      Get.snackbar('Error', 'Failed to create salary tracker: $e');
    }
  }

  Future<void> updateSalaryTracker(int trackerId, int staffId) async {
    if (!_validateSalaryInputs()) return;

    try {
      final trackerData = {
        "total_salary": double.tryParse(totalSalaryController.text) ?? 0,
        "payment_date": paymentDateController.text,
        "payment_mode": paymentModeController.text,
        "transaction_type": "salary",
      };

      await staffRepository.editSalaryTracker(trackerId, trackerData);
      //Get.snackbar('Success', 'Salary Tracker updated successfully');

      await fetchSalaryTrackers(staffId); // Refresh list
      clearControllers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update salary tracker: $e');
    }
  }

  Future<void> deleteSalaryTracker(int trackerId, int staffId) async {
    try {
      await staffRepository.deleteSalaryTracker(trackerId);
      //Get.snackbar('Success', 'Salary Tracker deleted successfully');

      await fetchSalaryTrackers(staffId); // Refresh list
    } catch (e) {
      //Get.snackbar('Error', 'Failed to delete salary tracker: $e');
    }
  }

  Future<void> fetchSalaryTrackers(int staffId) async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getSalaryTrackers(staffId);
      salaryTrackers.assignAll(result);
    } catch (e) {
      //Get.snackbar('Error', 'Failed to fetch salary trackers: $e');
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Salary Transaction ----------------
  Future<void> createSalaryTransaction(
      Map<String, dynamic> data, int staffId) async {
    try {
      print(data);
      await staffRepository.createSalaryTransaction(data);
      //Get.snackbar('Success', 'Salary transaction added');

      await fetchTransactions(staffId); // Refresh list
      await fetchSalaryTrackers(staffId);

      await expenseController.fetchExpenses();
    } catch (e) {
      //Get.snackbar('Error', 'Failed to add salary transaction: $e');
    }
  }

  Future<void> updateSalaryTransaction(
      int id, Map<String, dynamic> data, int staffId) async {
    try {
      print(data);
      print(id);
      await staffRepository.editSalaryTransaction(id, data);
      // Get.snackbar('Success', 'Salary transaction updated');

      await fetchTransactions(staffId); // Refresh list
      await fetchSalaryTrackers(staffId);
    } catch (e) {
      // Get.snackbar('Error', 'Failed to update salary transaction: $e');
    }
  }

  Future<void> deleteSalaryTransaction(int id, int staffId) async {
    try {
      await staffRepository.deleteSalaryTransaction(id);
      // Get.snackbar('Success', 'Salary transaction deleted');

      await fetchTransactions(staffId); // Refresh list
      await fetchSalaryTrackers(staffId);
      await expenseController.fetchExpenses();
    } catch (e) {
      // Get.snackbar('Error', 'Failed to delete salary transaction: $e');
    }
  }

  Future<void> fetchTransactions(int staffId) async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getTransactions(staffId);
      transactions.assignAll(result);
    } catch (e) {
      // Get.snackbar('Error', 'Failed to fetch transactions: $e');
      print('Error: Failed to fetch transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Search & Filter ----------------
  List<StaffModel> filterStaffs({String? query}) {
    final q = query?.toLowerCase() ?? '';
    var filtered = staffs.toList();

    if (q.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.designation.toLowerCase().contains(q) ||
            s.designationDisplay.toLowerCase().contains(q) || // new
            s.salaryMode.toLowerCase().contains(q) ||
            s.salaryModeDisplay.toLowerCase().contains(q) || // new
            s.email.toLowerCase().contains(q);
      }).toList();
    }

    if (startDateController.text.isNotEmpty) {
      final start = DateTime.parse(startDateController.text);
      filtered = filtered
          .where((s) =>
              s.joinedDate.isAfter(start) ||
              s.joinedDate.isAtSameMomentAs(start))
          .toList();
    }

    if (endDateController.text.isNotEmpty) {
      final end = DateTime.parse(endDateController.text);
      filtered = filtered
          .where((s) =>
              s.joinedDate.isBefore(end) || s.joinedDate.isAtSameMomentAs(end))
          .toList();
    }

    return filtered;
  }

  // ---------------- Clear Controllers ----------------
  void clearControllers() {
    nameController.clear();
    designationController.clear();
    salaryModeController.clear();
    phoneController.clear();
    addressController.clear();
    emailController.clear();
    isActiveController.value = true;

    totalSalaryController.clear();
    paymentDateController.clear();
    paymentModeController.clear();
    transactionAmountController.clear();
    transactionNoteController.clear();
  }

  // ---------------- Validation ----------------
  bool _validateStaffInputs() {
    if (nameController.text.isEmpty) {
      //   Get.snackbar('Error', 'Name is required');
      return false;
    }
    if (designationController.text.isEmpty) {
      // Get.snackbar('Error', 'Designation is required');
      return false;
    }
    if (salaryModeController.text.isEmpty) {
      //Get.snackbar('Error', 'Salary mode is required');
      return false;
    }
    return true;
  }

  bool _validateSalaryInputs() {
    if (totalSalaryController.text.isEmpty ||
        double.tryParse(totalSalaryController.text) == null) {
      // Get.snackbar('Error', 'Valid total salary is required');
      return false;
    }
    if (paymentDateController.text.isEmpty) {
      //Get.snackbar('Error', 'Payment date is required');
      return false;
    }
    if (paymentModeController.text.isEmpty) {
      //Get.snackbar('Error', 'Payment mode is required');
      return false;
    }
    return true;
  }
}
