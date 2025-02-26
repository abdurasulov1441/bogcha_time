import 'package:flutter/material.dart';

class NeumorphicCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const NeumorphicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  _NeumorphicCheckboxState createState() => _NeumorphicCheckboxState();
}

class _NeumorphicCheckboxState extends State<NeumorphicCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: widget.value
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(3, 3),
                      blurRadius: 5),
                  const BoxShadow(
                      color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
                ]
              : [
                  const BoxShadow(
                      color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(3, 3),
                      blurRadius: 5),
                ],
        ),
        child: widget.value
            ? const Icon(Icons.check, color: Color(0xFF3D8D7A))
            : null,
      ),
    );
  }
}
