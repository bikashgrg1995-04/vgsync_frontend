import 'package:flutter/material.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/navigation/main_content.dart';
import 'package:vgsync_frontend/app/wigdets/sidebar.dart';
import '../stock/stock_controller.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final GlobalController globalController = Get.find();
  final StockController stockController = Get.find();

  bool _isLoading = true;
  String _loadingMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Loading data...';
      });
      await stockController.fetchStocks();
    } catch (e) {
      // Handle errors if necessary
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          _isLoading ? Center(child: CircularProgressIndicator(semanticsLabel: _loadingMessage)) : MainContent(),
        ],
      ),
    );
  }
}
