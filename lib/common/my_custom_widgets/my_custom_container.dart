import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin; 

  const NeumorphicContainer({super.key, required this.child, this.width, this.height, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
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
