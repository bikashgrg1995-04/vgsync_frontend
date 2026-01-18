import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopToast {
  static final _entries = <OverlayEntry>[];

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
  }) {
    final overlayState = Get.key.currentState?.overlay ?? Overlay.of(Get.context!);

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 30.0 + (_entries.length * 60), // stack multiple messages
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(entry);
    _entries.add(entry);

    // Auto remove after duration
    Future.delayed(duration, () {
      entry.remove();
      _entries.remove(entry);
    });
  }
}
