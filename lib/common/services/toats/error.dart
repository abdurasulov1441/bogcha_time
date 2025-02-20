import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showErrorToast(BuildContext context, String title, String message) {
  toastification.show(
    context: context,
    animationBuilder: (context, animation, alignment, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    title: Text(title),
    description: Text(message),
    alignment: Alignment.topRight,
    backgroundColor: Colors.red.shade700,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.error, color: Colors.white),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
