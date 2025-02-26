import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class NeumorphicTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final bool isEmailvalidator;


  NeumorphicTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.isEmailvalidator = false,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  final EmailValidator emailValidator = EmailValidator();

  @override
  Widget build(BuildContext context) {
     
      
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(3, 3),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(-3, -3),
            blurRadius: 5,
          ),
        ],
      ),
      child: TextFormField(
      
        style: AppStyle.fontStyle.copyWith(color: AppColors.textColor),
        controller: widget.controller,
        obscureText: widget.isPassword,
        
        decoration: InputDecoration(
         
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        validator: (value) {
          if (!widget.isEmailvalidator) {
           return value != null && value.length < 6
                ? 'Parol kamida 6 belgidan iborat bo\'lishi kerak'.tr()
                : null;
          }
                            
          if (widget.isEmailvalidator) {
            return value != null && !EmailValidator.validate(value)
                ? 'To\'g\'ri email kiriting'.tr()
                : null;
          }
          return null;
        },
      ),
    );
  }
}
