import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/followup_model.dart';
import '../../data/repositories/followup_repository.dart';
import '../../controllers/global_controller.dart';

class FollowUpController extends GetxController {
  final FollowUpRepository followUpRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  FollowUpController({required this.followUpRepository});

  var followUps = <FollowUpModel>[].obs;
  var isLoading = false.obs;

  // ---------------- TEXT CONTROLLERS ----------------
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchFollowUps();
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ---------------- FETCH ----------------
  Future<void> fetchFollowUps() async {
    isLoading.value = true;
    try {
      final list = await followUpRepository.getFollowUps();
      followUps.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- TERMINATE ----------------
  Future<void> terminateFollowUp(int id) async {
    try {
      await followUpRepository.terminate(id);

      // 🔹 Update local followup status only
      final index = followUps.indexWhere((f) => f.id == id);
      if (index != -1) {
        followUps[index] = FollowUpModel(
          id: followUps[index].id,
          sale: followUps[index].sale,
          customerName: followUps[index].customerName,
          contactNo: followUps[index].contactNo,
          vehicle: followUps[index].vehicle,
          deliveryDate: followUps[index].deliveryDate,
          postServiceFeedbackDate: followUps[index].postServiceFeedbackDate,
          followUpDate: followUps[index].followUpDate,
          remarks: followUps[index].remarks,
          assignedTo: followUps[index].assignedTo,
          status: 'terminated', // 🔴 important
          reason: followUps[index].reason,
          createdAt: followUps[index].createdAt,
          updatedAt: DateTime.now(),
        );
      }

      // 🔹 Trigger dashboard refresh (followups only)
      globalController.triggerRefresh(DashboardRefreshType.followup);

      Get.snackbar('Success', 'Follow-up terminated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ---------------- FILTER ----------------
  List<FollowUpModel> filterFollowUps({
    String? query,
    DateTime? start,
    DateTime? end,
  }) {
    return followUps.where((f) {
      final matchesQuery = query == null ||
          query.isEmpty ||
          f.remarks.toString().toLowerCase().contains(query.toLowerCase()) ||
          f.customerName.toLowerCase().contains(query.toLowerCase()) ||
          f.sale.toString().contains(query);

      final serviceDate = f.deliveryDate;
      final matchesDate = (start == null ||
              serviceDate == null ||
              serviceDate.isAfter(start.subtract(const Duration(days: 1)))) &&
          (end == null ||
              serviceDate == null ||
              serviceDate.isBefore(end.add(const Duration(days: 1))));

      return matchesQuery && matchesDate;
    }).toList();
  }
}
