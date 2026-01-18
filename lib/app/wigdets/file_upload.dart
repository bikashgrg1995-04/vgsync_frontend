import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class FileUploadDialog {
  /// Generic file upload dialog
  /// [endpoint] => API endpoint to send file
  /// [fileKey] => key in FormData for file, e.g., 'file'
  /// [allowedExtensions] => ['xls','xlsx','csv'] etc
  static void show({
    required BuildContext context,
    required String title,
    required String endpoint,
    String fileKey = 'file',
    List<String> allowedExtensions = const ['xls', 'xlsx'],
    Function()? onSuccess,
  }) async {
    File? selectedFile;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          double progress = 0.0;
          bool isUploading = false;

          Future<void> uploadFile() async {
            if (selectedFile == null) {
              DesktopToast.show(
                'Please select a file first',
                backgroundColor: Colors.orangeAccent,
              );
              return;
            }

            setState(() {
              isUploading = true;
              progress = 0.0;
            });

            try {
              String fileName = selectedFile!.path.split('/').last;
              dio.FormData formData = dio.FormData.fromMap({
                fileKey: await dio.MultipartFile.fromFile(
                  selectedFile!.path,
                  filename: fileName,
                ),
              });

              final response = await ApiService.dio.post(
                endpoint,
                data: formData,
                onSendProgress: (sent, total) {
                  setState(() {
                    progress = sent / total;
                  });
                },
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                DesktopToast.show(
                  'File uploaded successfully!',
                  backgroundColor: Colors.greenAccent,
                );
                Get.back();
                if (onSuccess != null) onSuccess();
              } else {
                DesktopToast.show(
                  'Upload failed: ${response.data}',
                  backgroundColor: Colors.redAccent,
                );
              }
            } catch (e) {
              DesktopToast.show(
                'Error uploading file: $e',
                backgroundColor: Colors.redAccent,
              );
            } finally {
              setState(() {
                isUploading = false;
              });
            }
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: SizeConfig.sw(0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: SizeConfig.sh(0.02)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                          selectedFile?.path.split('/').last ?? 'Select File'),
                      onPressed: isUploading
                          ? null
                          : () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: allowedExtensions,
                              );

                              if (result != null &&
                                  result.files.single.path != null) {
                                setState(() {
                                  selectedFile =
                                      File(result.files.single.path!);
                                });
                              }
                            },
                    ),
                    SizedBox(height: SizeConfig.sh(0.02)),
                    if (isUploading)
                      LinearProgressIndicator(
                        value: progress,
                      ),
                    SizedBox(height: SizeConfig.sh(0.02)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isUploading ? null : uploadFile,
                          child: const Text('Upload'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
