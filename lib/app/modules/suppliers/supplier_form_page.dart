import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierFormPage extends StatelessWidget {
  const SupplierFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments?['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text(id != null ? 'Edit Supplier' : 'Add Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
