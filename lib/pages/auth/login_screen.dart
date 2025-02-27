import 'dart:math';

import 'package:bogcha_time/common/language/language_select_page.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_avatar.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_chekbox.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHiddenPassword = true;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();

    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }


  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (emailTextInputController.text =="admin" &&
          passwordTextInputController.text =="123456") {
 context.go(Routes.gardenPage);
        return;
        
      }
    else{print("error");}
  }

  @override
  Widget build(BuildContext context) {
  final String currentFlag = context.locale == const Locale('uz')
    ? '🇺🇿'
    : context.locale == const Locale('ru')
        ? '🇷🇺'
        : context.locale == const Locale('en')
            ? '🇬🇧'
            : '🇺🇿'; 


    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => showLanguageBottomSheet(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 25,
                        child: Text(
                          currentFlag,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                  Center(
                    
                    child: NeumorphicAvatar(
                      width: 100,
                      height: 100,
                      isAsset: true,
                      imageUrl: "assets/images/logo.jpg",
                    ),
                  ),
                 
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Bog\'cha Time',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'slogan'.tr(),
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NeumorphicTextField(
                    isLogin: true,
                    isPhoneNumber: false,
                    controller: emailTextInputController,
                    hintText: 'enter_login'.tr(),

                  ),
                  const SizedBox(height: 20),
                  NeumorphicTextField(
                    isEmailvalidator: false,
                    isPhoneNumber: false,
                    controller: passwordTextInputController,
                    hintText: 'enter_password'.tr(),
                    isPassword: isHiddenPassword,
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'show_password'.tr(),
                        style: AppStyle.fontStyle.copyWith(),
                      ),
                      SizedBox(width: 10),
                      NeumorphicCheckbox(
                        value: !isHiddenPassword,
                        onChanged: (value) {
                          setState(() {
                            isHiddenPassword = !value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NeumorphicButton(
                    isDisabled: false,
                    text: "login".tr(),
                    onPressed: () => login(),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.push(Routes.resetPasswordPage);
                        },
                        child: Text(
                          'forgot_password'.tr(),
                          style: AppStyle.fontStyle.copyWith(),
                        ),
                      ),
                    ],
                  ),
                 
                  SizedBox(height: 20),
                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
