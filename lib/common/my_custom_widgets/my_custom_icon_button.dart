
import 'package:flutter/material.dart';

class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const NeumorphicIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
            BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF3D8D7A)),
      ),
    );
  }
}