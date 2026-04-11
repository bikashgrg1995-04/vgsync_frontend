import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../data/models/followup_model.dart';
import '../../data/repositories/followup_repository.dart';
import '../../controllers/global_controller.dart';

class FollowUpController extends GetxController {
  final FollowUpRepository followUpRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  FollowUpController({required this.followUpRepository});

  final RxList<FollowUpModel> followUps = <FollowUpModel>[].obs;
  final RxBool isLoading = false.obs;

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

  Future<void> terminateFollowUp(int id, {String? reason}) async {
    try {
      await followUpRepository.terminate(
        id,
      );

      final index = followUps.indexWhere((f) => f.id == id);
      if (index != -1) {
        final old = followUps[index];

        followUps[index] = old.copyWith(
          status: 'terminated',
          reason: reason ?? old.reason,
          updatedAt: DateTime.now(),
        );
      }

      globalController.triggerRefresh(
        DashboardRefreshType.followup,
      );
      DesktopToast.show(
        'Follow-up terminated successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to terminate follow-up',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  // ---------------- FILTER ----------------
  List<FollowUpModel> filterFollowUps({
    String? query,
    DateTime? start,
    DateTime? end,
  }) {
    return followUps.where((f) {
      final q = query?.toLowerCase() ?? '';

      final matchesQuery = q.isEmpty ||
          f.customerName.toLowerCase().contains(q) ||
          (f.contactNo ?? '').toLowerCase().contains(q) ||
          (f.vehicle ?? '').toLowerCase().contains(q) ||
          (f.remarks ?? '').toLowerCase().contains(q) ||
          f.saleId.toString().contains(q);

      final serviceDate = f.deliveryDate;
      final matchesDate = (start == null ||
              serviceDate == null ||
              serviceDate.isAfter(
                start.subtract(const Duration(days: 1)),
              )) &&
          (end == null ||
              serviceDate == null ||
              serviceDate.isBefore(
                end.add(const Duration(days: 1)),
              ));

      return matchesQuery && matchesDate;
    }).toList();
  }
}
