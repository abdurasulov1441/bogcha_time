import 'package:flutter/material.dart';

class NeumorphicSwitch extends StatefulWidget {
  const NeumorphicSwitch({super.key});

  @override
  _NeumorphicSwitchState createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOn = !isOn;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
            BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
          ],
        ),
        child: Row(
          mainAxisAlignment: isOn ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(3),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFF3D8D7A) : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                  BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(2, 2), blurRadius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}