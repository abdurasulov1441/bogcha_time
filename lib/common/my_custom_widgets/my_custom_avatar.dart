
import 'package:flutter/material.dart';

class NeumorphicAvatar extends StatelessWidget {
  final String imageUrl;

  const NeumorphicAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF9),
        shape: BoxShape.circle,
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
          BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}