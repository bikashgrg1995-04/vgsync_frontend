import '../models/staff_model.dart';
import '../services/staff_service.dart';

class StaffRepository {
  final StaffService staffService;

  StaffRepository({required this.staffService});

  // ---------------- Staff CRUD ----------------
  Future<List<StaffModel>> getStaffs() => staffService.getStaffs();
  Future<StaffModel> create(StaffModel staff) =>
      staffService.createStaff(staff);
  Future<StaffModel> update(StaffModel staff) =>
      staffService.updateStaff(staff);
  Future<void> delete(int id) => staffService.deleteStaff(id);

  // ---------------- Salary Tracker CRUD ----------------
  Future<void> createSalaryTracker(Map<String, dynamic> data) =>
      staffService.createSalaryTracker(data);

  Future<void> editSalaryTracker(int id, Map<String, dynamic> payload) =>
      staffService.editSalaryTracker(id, payload);

  Future<void> deleteSalaryTracker(int id) =>
      staffService.deleteSalaryTracker(id);

  // ** New method to fetch salary trackers for a staff **
  Future<List<Map<String, dynamic>>> getSalaryTrackers(int staffId) =>
      staffService.getSalaryTrackers(staffId);

  // ---------------- Salary Transaction CRUD ----------------
  Future<void> createSalaryTransaction(Map<String, dynamic> payload) =>
      staffService.createSalaryTransaction(payload);

  Future<void> editSalaryTransaction(int id, Map<String, dynamic> payload) =>
      staffService.editSalaryTransaction(id, payload);

  Future<void> deleteSalaryTransaction(int id) =>
      staffService.deleteSalaryTransaction(id);

  // ** New method to fetch salary transactions for a staff **
  Future<List<Map<String, dynamic>>> getTransactions(int staffId) =>
      staffService.getTransactions(staffId);
}
