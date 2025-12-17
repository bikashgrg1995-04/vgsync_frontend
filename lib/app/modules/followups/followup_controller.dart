import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/followup_model.dart';
import '../../data/repositories/followup_repository.dart';

class FollowUpController extends GetxController {
  final FollowUpRepository followUpRepository;

  FollowUpController({required this.followUpRepository});

  var followUps = <FollowUpModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  final formKey = GlobalKey<FormState>();
  final saleController = TextEditingController();
  final serviceDateController = TextEditingController();
  final followUpDateController = TextEditingController();
  final remarksController = TextEditingController();
  var completed = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFollowUps();
  }

  /// increases whenever any data changes
  final RxInt refreshTick = 0.obs;
  void triggerRefresh() {
    refreshTick.value++;
  }

  void fillForm(FollowUpModel followUp) {
    saleController.text = followUp.sale.toString();
    serviceDateController.text = followUp.serviceDate;
    followUpDateController.text = followUp.followUpDate;
    remarksController.text = followUp.remarks;
    completed.value = followUp.completed;
  }

  void clearForm() {
    saleController.clear();
    serviceDateController.clear();
    followUpDateController.clear();
    remarksController.clear();
    completed.value = false;
  }

  Future<void> fetchFollowUps() async {
    isLoading.value = true;
    final list = await followUpRepository.getAllFollowUps();
    followUps.assignAll(list); // Updates RxList -> UI auto rebuild
    isLoading.value = false;
  }

  Future<void> updateFollowUp(FollowUpModel updatedFollowUp) async {
    final updated = await followUpRepository.updateFollowUp(updatedFollowUp);
    final index = followUps.indexWhere((f) => f.id == updated.id);
    if (index != -1) followUps[index] = updated; // triggers UI rebuild
  }

  void delete(int id) async {
    await followUpRepository.deleteFollowUp(id);
    followUps.removeWhere((f) => f.id == id); // triggers UI rebuild
  }
}
