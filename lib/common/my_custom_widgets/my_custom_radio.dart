
import 'package:flutter/material.dart';

class NeumorphicRadio extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const NeumorphicRadio({super.key, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
            BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
          ],
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D8D7A),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

