import 'package:flutter/material.dart';

class NeumorphicCheckbox extends StatefulWidget {
  const NeumorphicCheckbox({super.key});

  @override
  _NeumorphicCheckboxState createState() => _NeumorphicCheckboxState();
}

class _NeumorphicCheckboxState extends State<NeumorphicCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isChecked
              ? [
                  BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(3, 3), blurRadius: 5),
                  const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
                ]
              : [
                  const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
                  BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
                ],
        ),
        child: isChecked
            ? const Icon(Icons.check, color: Color(0xFF3D8D7A))
            : null,
      ),
    );
  }
}