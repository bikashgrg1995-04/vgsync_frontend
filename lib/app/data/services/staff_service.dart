import 'package:dio/dio.dart';
import '../models/staff_model.dart';
import 'api_service.dart';

class StaffService {
  final Dio _dio = ApiService.dio;

  // ---------------- Helper ----------------
  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  // ---------------- Staff CRUD ----------------
  Future<List<StaffModel>> getStaffs() async {
    final res = await _dio.get("/staffs/");
    return _extractList(res.data)
        .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StaffModel> createStaff(StaffModel staff) async {
    final res = await _dio.post("/staffs/", data: staff.toJson());
    return StaffModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StaffModel> updateStaff(StaffModel staff) async {
    final res = await _dio.put("/staffs/${staff.id}/", data: staff.toJson());
    return StaffModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteStaff(int id) async {
    await _dio.delete("/staffs/$id/");
  }

  // ---------------- Salary Tracker CRUD ----------------
  Future<void> createSalaryTracker(Map<String, dynamic> data) async {
    await _dio.post("/salarytracker/", data: data);
  }

  Future<void> editSalaryTracker(int id, Map<String, dynamic> payload) async {
    await _dio.put("/salarytracker/$id/", data: payload);
  }

  Future<void> deleteSalaryTracker(int id) async {
    await _dio.delete("/salarytracker/$id/");
  }

  // ** New function to fetch salary trackers for a specific staff **
  Future<List<Map<String, dynamic>>> getSalaryTrackers(int staffId) async {
    final res = await _dio.get("/salarytracker/", queryParameters: {"staff": staffId});
    return List<Map<String, dynamic>>.from(_extractList(res.data));
  }

  // ---------------- Salary Transaction CRUD ----------------
  Future<void> createSalaryTransaction(Map<String, dynamic> payload) async {
    await _dio.post("/salarytransactions/", data: payload);
  }

  Future<void> editSalaryTransaction(
      int id, Map<String, dynamic> payload) async {
    await _dio.put("/salarytransactions/$id/", data: payload);
  }

  Future<void> deleteSalaryTransaction(int id) async {
    await _dio.delete("/salarytransactions/$id/");
  }

  // ** New function to fetch salary transactions for a specific staff **
  Future<List<Map<String, dynamic>>> getTransactions(int staffId) async {
    final res = await _dio.get("/salarytransactions/", queryParameters: {"staff": staffId});
    return List<Map<String, dynamic>>.from(_extractList(res.data));
  }
}
