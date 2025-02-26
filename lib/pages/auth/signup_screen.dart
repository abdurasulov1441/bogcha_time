import 'package:email_validator/email_validator.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  bool isHiddenPassword = true;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();
    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (passwordTextInputController.text !=
        passwordTextRepeatInputController.text) {
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return;
      } else {
        return;
      }
    }

    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Yangi akkaunt yarating',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  ''.toUpperCase(),
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  style: AppStyle.fontStyle,
                  controller: emailTextInputController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.foregroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Email kiriting',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  validator:
                      (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'To\'g\'ri email kiriting'
                              : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: AppStyle.fontStyle,
                  controller: passwordTextInputController,
                  obscureText: isHiddenPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.foregroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Parol kiriting',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHiddenPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: togglePasswordView,
                    ),
                  ),
                  validator:
                      (value) =>
                          value != null && value.length < 6
                              ? 'Parol kamida 6 ta belgi bo\'lishi kerak'
                              : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: AppStyle.fontStyle,
                  controller: passwordTextRepeatInputController,
                  obscureText: isHiddenPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.foregroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Parolni takror kiriting',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHiddenPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: togglePasswordView,
                    ),
                  ),
                  validator:
                      (value) =>
                          value != null && value.length < 6
                              ? 'Parol kamida 6 ta belgi bo\'lishi kerak'
                              : null,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: signUp,
                    child: Text(
                      'Ro\'yxatdan o\'tish',
                      style: AppStyle.fontStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Akkauntingiz bormi? Kirish',
                      style: AppStyle.fontStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
