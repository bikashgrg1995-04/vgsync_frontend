import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFormDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final bool isEditMode;
  final bool isSaving;

  const CustomFormDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onSave,
    this.onDelete,
    this.isEditMode = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ----------- TITLE -----------
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ----------- FORM CONTENT -----------
              content,
              const SizedBox(height: 24),

              // ----------- ACTION BUTTONS -----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isEditMode && onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    const SizedBox(width: 10),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: Icon(isEditMode ? Icons.save : Icons.add),
                    label: Text(isEditMode ? "Update" : "Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditMode
                          ? Colors.orangeAccent
                          : Colors.greenAccent.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
