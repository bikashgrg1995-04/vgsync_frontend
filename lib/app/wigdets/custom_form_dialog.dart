import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class CustomFormDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final double height;
  final double width;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final bool isEditMode;
  final bool isSaving;

  const CustomFormDialog({
    super.key,
    required this.title,
    required this.content,
    required this.height,
    required this.width,
    required this.onSave,
    this.onDelete,
    this.isEditMode = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: SizeConfig.sh(height),
        width: SizeConfig.sw(width),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.res(6)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: SizeConfig.sh(0.8),
              maxWidth: 400,
            ),
            child: Column(
              children: [
                // ----------- TITLE -----------
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.sh(0.02)),

                // ----------- SCROLLABLE CONTENT -----------
                Expanded(
                  child: content,
                ),

                SizedBox(height: SizeConfig.sh(0.02)),

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
      ),
    );
  }
}
