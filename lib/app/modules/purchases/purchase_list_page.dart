import 'package:flutter/material.dart';

class PurchaseListPage extends StatelessWidget {
  const PurchaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchases')),
      body: const Center(child: Text('Purchase List Page (Demo)')),
    );
  }
}
