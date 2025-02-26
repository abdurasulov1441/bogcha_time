import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  const NeumorphicContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
          BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(5, 5), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}
