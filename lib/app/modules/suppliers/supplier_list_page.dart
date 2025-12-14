import 'package:flutter/material.dart';

class SupplierListPage extends StatelessWidget {
  const SupplierListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: const Center(child: Text('Supplier List Page (Demo)')),
    );
  }
}
