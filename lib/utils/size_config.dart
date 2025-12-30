import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;

  /// Call this in `build()` or Splash before using sizes
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
  }

  /// Percentage of screen width
  static double sw(double percentage) {
    return screenWidth * percentage;
  }

  /// Percentage of screen height
  static double sh(double percentage) {
    return screenHeight * percentage;
  }

  /// Responsive text size based on screen width
  static double res(double size) {
    // base width is 375 (iPhone 13)
    return size * screenWidth / 375;
  }
}
