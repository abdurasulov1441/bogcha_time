
import 'package:flutter/material.dart';

class NeumorphicDropdown extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String?) onChanged;

  const NeumorphicDropdown({super.key, required this.items, required this.selectedItem, required this.onChanged});

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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedItem,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
