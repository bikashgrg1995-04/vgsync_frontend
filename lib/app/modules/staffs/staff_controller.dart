import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../data/models/staff_model.dart';
import '../../data/repositories/staff_repository.dart';

class StaffController extends GetxController {
  final StaffRepository staffRepository;

  StaffController({required this.staffRepository});

  // ---------------- Reactive variables ----------------
  var staffs = <StaffModel>[].obs;
  var isLoading = false.obs;

  final ExpenseController expenseController = Get.find<ExpenseController>();
  final globalController = Get.find<GlobalController>();

  final searchController = TextEditingController();

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

  @override
  void onInit() {
    super.onInit();
    fetchStaff(); // ✅ SAFE
  }

  void setStaffFilters() {
    searchController.clear();
    fetchStaff();
  }

  void fillStaffForm(StaffModel e) {
    nameController.text = e.name;
    designationController.text = e.designation;
    salaryModeController.text = e.salaryMode;
    phoneController.text = e.phone;
    emailController.text = e.email ?? "";
    isActiveController.value = e.isActive;
    addressController.text = e.address ?? "";
  }

  // ---------------- Fetch Staff ----------------
  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getStaffs();
      staffs.assignAll(result);
    } catch (e) {
      DesktopToast.show(
        'Failed to fetch staff: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add / Update Staff ----------------
  Future<void> addStaff({bool withSalaryTracker = false}) async {
    if (!_validateStaffInputs()) return;

    try {
      isLoading.value = true;
      final newStaff = StaffModel(
        name: nameController.text,
        designation: designationController.text,
        designationDisplay: designationController.text,
        salaryMode: salaryModeController.text,
        salaryModeDisplay: salaryModeController.text,
        phone: phoneController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        address: addressController.text.isEmpty ? null : addressController.text,
        isActive: isActiveController.value,
        joinedDate: DateTime.now(),
      );

      final added = await staffRepository.create(newStaff);
      staffs.add(added);
      await fetchStaff();
      globalController.triggerRefresh(DashboardRefreshType.staff);

      clearControllers();

      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Staff created successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      Get.back(closeOverlays: true);
      DesktopToast.show(
        "Failed to add staff: $e",
        backgroundColor: Colors.redAccent,
      );
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
        designationDisplay: designationController.text,
        salaryMode: salaryModeController.text,
        salaryModeDisplay: salaryModeController.text,
        phone: phoneController.text,
        email: emailController.text,
        address: addressController.text,
        isActive: isActiveController.value,
        joinedDate: staff.joinedDate,
      );

      final updated = await staffRepository.update(updatedStaff);
      final index = staffs.indexWhere((s) => s.id == updated.id);
      if (index != -1) staffs[index] = updated;
      await fetchStaff();
      globalController.triggerRefresh(DashboardRefreshType.staff);
      clearControllers();

      Get.back(closeOverlays: true);
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Staff updated successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      Get.back(closeOverlays: true);
      DesktopToast.show(
        "Error: ${e.toString()}",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Staff ----------------
  Future<void> deleteStaff(int id) async {
    ConfirmDialog.show(
      Get.context!,
      title: 'Delete Staff',
      message: 'Are you sure you want to delete this staff?',
      onConfirm: () async {
        try {
          isLoading.value = true;
          await staffRepository.delete(id);
          staffs.removeWhere((e) => e.id == id);
          await fetchStaff();
          globalController.triggerRefresh(DashboardRefreshType.staff);
          Get.back(closeOverlays: true);
          Get.back(closeOverlays: true);
          DesktopToast.show(
            'Staff deleted successfully',
            backgroundColor: Colors.greenAccent,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
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
      await refreshStaffData(staffId); // Refresh data immediately
      clearControllers(); // Reset controllers
    } catch (e) {
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Failed to create salary tracker: $e',
        backgroundColor: Colors.redAccent,
      );
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
       await refreshStaffData(staffId); // Refresh tracker & transactions
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Salary Tracker updated successfully',
        backgroundColor: Colors.greenAccent,
      );

      clearControllers();
    } catch (e) {
      DesktopToast.show(
        'Failed to update salary tracker: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> deleteSalaryTracker(int trackerId, int staffId) async {
    try {
      await staffRepository.deleteSalaryTracker(trackerId);
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Salary Tracker deleted successfully',
        backgroundColor: Colors.greenAccent,
      );
      await refreshStaffData(staffId); // Refresh data
    } catch (e) {
      DesktopToast.show(
        'Failed to delete salary tracker: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> fetchSalaryTrackers(int staffId) async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getSalaryTrackers(staffId);
      salaryTrackers.assignAll(result);
    } catch (e) {
      DesktopToast.show(
        'Failed to fetch salary trackers: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Salary trackers for dialog ----------------
  List<Map<String, dynamic>> get salaryTrackersForDialog {
    return salaryTrackers.toList();
  }

  // ---------------- Salary Transaction ----------------
  Future<void> createSalaryTransaction(Map<String, dynamic> data, int staffId) async {
    try {
      await staffRepository.createSalaryTransaction(data);
      await refreshStaffData(staffId); // Refresh tracker & transactions
      DesktopToast.show(
        'Salary transaction added successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to add salary transaction: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> updateSalaryTransaction(int id, Map<String, dynamic> data, int staffId) async {
    try {
      await staffRepository.editSalaryTransaction(id, data);
      await refreshStaffData(staffId); // Refresh tracker & transactions
      DesktopToast.show(
        'Salary transaction updated successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to update salary transaction: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> deleteSalaryTransaction(int id, int staffId) async {
    try {
      await staffRepository.deleteSalaryTransaction(id);
      await refreshStaffData(staffId); // Refresh tracker & transactions
      DesktopToast.show(
        'Salary transaction deleted successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to delete salary transaction: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> fetchTransactions(int staffId) async {
    try {
      isLoading.value = true;
      final result = await staffRepository.getTransactions(staffId);
      transactions.assignAll(result);
    } catch (e) {
      DesktopToast.show(
        'Failed to fetch transactions: $e',
        backgroundColor: Colors.redAccent,
      );
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
            s.designation.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  // ---------------- Refresh Staff Data ----------------
  Future<void> refreshStaffData(int staffId) async {
    await fetchSalaryTrackers(staffId);
    await fetchTransactions(staffId);
    await expenseController.fetchExpenses();
    globalController.triggerRefresh(DashboardRefreshType.staff);
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
      DesktopToast.show("Name is required", backgroundColor: Colors.redAccent);
      return false;
    }
    if (designationController.text.isEmpty) {
      DesktopToast.show("Designation is required", backgroundColor: Colors.redAccent);
      return false;
    }
    if (phoneController.text.isEmpty) {
      DesktopToast.show("Contact is required", backgroundColor: Colors.redAccent);
      return false;
    }
    if (salaryModeController.text.isEmpty) {
      DesktopToast.show("Salary Mode is required", backgroundColor: Colors.redAccent);
      return false;
    }
    return true;
  }

  bool _validateSalaryInputs() {
    if (totalSalaryController.text.isEmpty ||
        double.tryParse(totalSalaryController.text) == null) {
      DesktopToast.show('Valid total salary is required', backgroundColor: Colors.redAccent);
      return false;
    }
    if (paymentDateController.text.isEmpty) {
      DesktopToast.show('Payment date is required', backgroundColor: Colors.redAccent);
      return false;
    }
    if (paymentModeController.text.isEmpty) {
      DesktopToast.show('Payment mode is required', backgroundColor: Colors.redAccent);
      return false;
    }
    return true;
  }

  /// Returns the next unpaid tracker for staff, or latest tracker if all paid
  Map<String, dynamic>? getNextSalaryTracker(int staffId) {
    final trackers = salaryTrackers.where((t) => t['staff'] == staffId).toList();
    if (trackers.isEmpty) return null;

    // First, check unpaid trackers
    final unpaid = trackers.where((t) => (t['remaining_amount'] ?? 0) > 0).toList();
    if (unpaid.isNotEmpty) {
      unpaid.sort((a, b) {
        final dateA = DateTime.tryParse(a['payment_date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['payment_date'] ?? '') ?? DateTime(2000);
        return dateA.compareTo(dateB);
      });
      return unpaid.first;
    }

    // fallback: return latest tracker if all paid
    trackers.sort((a, b) {
      final dateA = DateTime.tryParse(a['payment_date'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['payment_date'] ?? '') ?? DateTime(2000);
      return dateA.compareTo(dateB);
    });
    return trackers.last;
  }
}
