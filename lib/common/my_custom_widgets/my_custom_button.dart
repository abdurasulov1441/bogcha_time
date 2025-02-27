import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? prefixImage;
  final VoidCallback onPressed;
  final bool isIconOnly;
  final bool isDisabled;
  

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isIconOnly = false,
    this.isDisabled = false,
    this.prefixImage,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.defoltColor1 : const Color(0xFFEBEEF9),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && prefixImage==null) Icon(icon, color: const Color(0xFF3D8D7A)),
            if (prefixImage != null) Image.asset(prefixImage!, width: 24, height: 24),
            if (!isIconOnly) ...[
              const SizedBox(width: 10),
              Text(text, style:  TextStyle(fontSize: 16, color: isDisabled ? AppColors.foregroundColor : const Color(0xFF3D8D7A))),
            ],
          ],
        ),
      ),
    );
  }
}
