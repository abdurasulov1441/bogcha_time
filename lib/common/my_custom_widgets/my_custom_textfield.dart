
import 'package:flutter/material.dart';

class NeumorphicTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;

  const NeumorphicTextField({super.key, required this.hintText, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(3, 3), blurRadius: 5),
          BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(-3, -3), blurRadius: 5),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}