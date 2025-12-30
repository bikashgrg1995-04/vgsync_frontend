import 'package:vgsync_frontend/app/modules/navigation/main_content.dart';
import 'package:vgsync_frontend/app/wigdets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/global_controller.dart';

class NavigationPage extends StatelessWidget {
  NavigationPage({super.key});

  final GlobalController globalController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(), // Left menu
          MainContent(), // Right main content area with animations
        ],
      ),
    );
  }
}
