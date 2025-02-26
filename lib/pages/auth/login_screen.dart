import 'package:bogcha_time/common/language/language_select_page.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_avatar.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_chekbox.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_container.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (!docSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'name': user.displayName ?? '',
                'email': user.email ?? '',
                'photoUrl': user.photoURL ?? '',
                'phone': user.phoneNumber ?? '',
                'created_at': FieldValue.serverTimestamp(),
              });
        }

        context.go(Routes.firebaseStream);
      }
    } catch (e) {
      print('Ошибка входа через Google: $e');
    }
  }

  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      } else {}
    }
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
                      'Tez, qulay, oson',
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NeumorphicTextField(
                    isEmailvalidator: true,
                    controller: emailTextInputController,
                    hintText: 'Emailingizni kiriting',
                  ),
                  const SizedBox(height: 20),
                  NeumorphicTextField(
                    isEmailvalidator: false,
                    controller: passwordTextInputController,
                    hintText: 'Parolingizni kiriting',
                    isPassword: isHiddenPassword,
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Parolni ko\'rsatish',
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
                    text: "Kirish",
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
                          'Parolni unutdingizmi?',
                          style: AppStyle.fontStyle.copyWith(),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(Routes.signUpPage),
                      child: Text(
                        'Hisobingiz yo\'qmi? Ro\'yxatdan o\'ting',
                        style: AppStyle.fontStyle.copyWith(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => signInWithGoogle(context),
                    child: NeumorphicContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/google.png', height: 24),
                          SizedBox(width: 10),
                          Text(
                            'Sign in with Google',
                            style: AppStyle.fontStyle.copyWith(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
