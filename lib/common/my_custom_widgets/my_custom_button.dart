import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isIconOnly;

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(5, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: const Color(0xFF3D8D7A)),
            if (!isIconOnly) ...[
              const SizedBox(width: 10),
              Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF3D8D7A))),
            ],
          ],
        ),
      ),
    );
  }
}
