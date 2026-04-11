// ------------------ Helper ------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

Widget buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? hintText,
  bool readOnly = false,
  VoidCallback? onTap,
  RxBool? obscureToggle,
}) {
  // 🔥 If password field → use Obx
  if (obscureToggle != null) {
    return Obx(() {
      return _buildField(
        controller,
        label,
        icon,
        obscureToggle.value,
        keyboardType,
        hintText,
        readOnly,
        onTap,
        obscureToggle,
      );
    });
  }

  // 🔥 Normal field → NO Obx
  return _buildField(
    controller,
    label,
    icon,
    obscureText,
    keyboardType,
    hintText,
    readOnly,
    onTap,
    null,
  );
}

Widget _buildField(
  TextEditingController controller,
  String label,
  IconData icon,
  bool obscureText,
  TextInputType keyboardType,
  String? hintText,
  bool readOnly,
  VoidCallback? onTap,
  RxBool? obscureToggle,
) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      suffixIcon: obscureToggle == null
          ? null
          : IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                obscureToggle.value = !obscureToggle.value;
              },
            ),
      labelText: label,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

//Confirm Dialog
class ConfirmDialog {
  /// Show a confirmation dialog
  /// [title] - dialog title
  /// [message] - description
  /// [onConfirm] - function to execute when user confirms
  /// [showSnackbarAfter] - whether to show a snackbar after confirming
  /// [snackbarMessage] - optional custom message for snackbar; defaults to title
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Yes",
    String cancelText = "No",
    bool showSnackbarAfter = false,
    String? snackbarMessage,
    Color snackbarColor = Colors.green,
    IconData snackbarIcon = Icons.check_circle,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // close dialog
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm(); // ✅ execute function first
              Get.back(); // ✅ then close dialog

              // // ✅ show snackbar if requested
              // if (showSnackbarAfter) {
              //   AppSnackbar.show(
              //     message: snackbarMessage ?? title,
              //     bgColor: snackbarColor,
              //     icon: snackbarIcon,
              //   );
              // }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

// Common Dropdown Widget
Widget commonDropdown(
  RxString value,
  String label,
  List<String> items,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Obx(
      () => DropdownButtonFormField<String>(
        value: value.value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (v) => value.value = v!,
        decoration: InputDecoration(labelText: label),
      ),
    ),
  );
}

class CommonBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CommonBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.03),
        vertical: SizeConfig.sh(0.01),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => Get.offAndToNamed(AppRoutes.navigation),
          child: Ink(
            padding: EdgeInsets.all(SizeConfig.res(2)),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: SizeConfig.res(6),
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}

Widget actionButton({
  required String label,
  required IconData icon,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    height: SizeConfig.sh(0.06),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
