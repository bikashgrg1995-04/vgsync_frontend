import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// A reusable base controller for all form pages.
/// Handles validation, save state, and feedback.
abstract class BaseFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSaving = false.obs;

  /// Override this in your child controller
  Future<void> onSubmit();

  /// Call this when the Save button is pressed
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      await onSubmit();
      Get.back();
      Get.snackbar(
        "Success",
        "Saved successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFFB00020),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
