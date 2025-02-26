import 'package:flutter/material.dart';

class NeumorphicSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;

  const NeumorphicSlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 100,
        activeColor: const Color(0xFF3D8D7A),
        inactiveColor: Colors.grey[300],
        onChanged: onChanged,
      ),
    );
  }

  
}