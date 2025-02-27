import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:flutter/material.dart';

class NeumorphicAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isAsset;
  final double? width;
  final double? height;

  const NeumorphicAvatar({
    super.key,
    required this.imageUrl,
    this.isAsset = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: width ?? 60,
      height: height ?? 60,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(3, 3),
            blurRadius: 5,
          ),
        ],
        image: DecorationImage(
          
          image: isAsset ? AssetImage(imageUrl) : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
