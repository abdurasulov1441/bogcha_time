import 'dart:math';

import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeumorphicTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final bool isEmailvalidator;
  final bool isPhoneNumber;
  final bool isLogin;
  final keyBoardType;


  NeumorphicTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.isEmailvalidator = false,
    TextEditingController? controller,
    this.isPhoneNumber = false,
    this.isLogin = false,
    this.keyBoardType,
  }) : controller = controller ?? TextEditingController();

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  final EmailValidator emailValidator = EmailValidator();
final _phoneNumberFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (!newValue.text.startsWith('+998 ')) {
        return TextEditingValue(
          text: '+998 ',
          selection: TextSelection.collapsed(offset: 5),
        );
      }

      String rawText =
          newValue.text.replaceAll(RegExp(r'[^0-9]'), '').substring(3);

      if (rawText.length > 9) {
        rawText = rawText.substring(0, 9);
      }

      String formattedText = '+998 ';
      if (rawText.isNotEmpty) {
        formattedText += '(${rawText.substring(0, min(2, rawText.length))}';
      }
      if (rawText.length > 2) {
        formattedText += ') ${rawText.substring(2, min(5, rawText.length))}';
      }
      if (rawText.length > 5) {
        formattedText += ' ${rawText.substring(5, min(7, rawText.length))}';
      }
      if (rawText.length > 7) {
        formattedText += ' ${rawText.substring(7)}';
      }

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    },
  );
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
        keyboardType: widget.keyBoardType,
        inputFormatters: widget.isPhoneNumber ? [_phoneNumberFormatter] : [],
        style: AppStyle.fontStyle.copyWith(color: AppColors.textColor),
        controller: widget.controller,
        obscureText: widget.isPassword,
        
        decoration: InputDecoration(
        
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        validator: (value) {
           if (widget.isPhoneNumber&&!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$')
                          .hasMatch(value!)) {
                        return 'enter_phone'.tr();
                      } 
                      if (widget.isLogin && value!.isEmpty) {
            return 'enter_login'.tr();
                        
                      }
          if (!widget.isEmailvalidator && !widget.isLogin) {
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
