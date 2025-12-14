import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_form_dialog.dart'; // Make sure this exists

class CommonDetailPage<T> extends StatelessWidget {
  final T data;
  final String title;
  final List<FieldData> fields;
  final Function(T)? onUpdate; // callback after edit
  final Function(T)? onDelete; // callback after delete
  final List<FieldData>? formFields; // fields for editing in dialog
  final bool showProfileImage; // new flag
  final String? profileImageUrl; // new optional image URL

  const CommonDetailPage({
    super.key,
    required this.data,
    required this.title,
    required this.fields,
    this.onUpdate,
    this.onDelete,
    this.formFields,
    this.showProfileImage = false,
    this.profileImageUrl,
  });

  void _showEditDialog(BuildContext context) {
    if (formFields == null || onUpdate == null) return;

    final controllers = <String, TextEditingController>{};
    for (var f in formFields!) {
      controllers[f.label] = TextEditingController(text: f.getter(data) ?? '');
    }

    final content = Column(
      children: formFields!
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: controllers[f.label],
                  decoration: InputDecoration(labelText: f.label),
                ),
              ))
          .toList(),
    );

    Get.dialog(
      CustomFormDialog(
        title: "Edit $title",
        isEditMode: true,
        content: content,
        isSaving: false,
        onSave: () {
          for (var f in formFields!) {
            f.updateData!(data, controllers[f.label]!.text);
          }
          onUpdate!(data);
          Get.back();
        },
        onDelete: () {
          Get.back(); // close dialog
          _confirmDelete(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    if (onDelete == null) return;

    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete this $title?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        onDelete!(data);
        Get.back();
        Get.back(); // close detail page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          if (onUpdate != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orangeAccent),
              onPressed: () => _showEditDialog(context),
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (showProfileImage)
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
              ),
            if (showProfileImage) const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: fields.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final field = fields[index];
                  final value = field.getter(data);
                  return ListTile(
                    title: Text(field.label,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(value ?? '-'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Field data for display
class FieldData<T> {
  final String label;
  final String? Function(T) getter;
  final void Function(T, String)? updateData; // optional update for edit

  FieldData({required this.label, required this.getter, this.updateData});
}
