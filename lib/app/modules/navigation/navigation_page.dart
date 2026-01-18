import 'package:flutter/material.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/navigation/main_content.dart';
import 'package:vgsync_frontend/app/wigdets/sidebar.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final GlobalController globalController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          MainContent(),
        ],
      ),
    );
  }
}
