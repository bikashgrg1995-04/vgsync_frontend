import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox('customers');
  await Hive.openBox('suppliers');
  await Hive.openBox('items');
  await Hive.openBox('categories');
  await Hive.openBox('sales');
  await Hive.openBox('purchases');
  await Hive.openBox('followups');

  InitialBinding().dependencies(); // Register all controllers

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VGSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: InitialBinding(), // binds global dependencies
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
