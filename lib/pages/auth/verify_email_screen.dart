import 'dart:async';
import 'package:bogcha_time/pages/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
      if (mounted) {}
    }
  }

  /// **🔹 Реаутентификация перед удалением аккаунта**
  Future<void> reauthenticateAndDelete() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      if (user.providerData.any((info) => info.providerId == 'password')) {
        // 🔹 Если пользователь вошел через email и пароль
        await _reauthenticateWithEmailPassword(user);
      } else if (user.providerData.any(
        (info) => info.providerId == 'google.com',
      )) {
        // 🔹 Если пользователь вошел через Google
        await _reauthenticateWithGoogle(user);
      }

      // ✅ После успешной реаутентификации удаляем аккаунт
      await user.delete();
      print('Аккаунт успешно удален');
    } catch (e) {
      print('Ошибка при удалении аккаунта: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    }
  }

  /// 🔹 Реаутентификация через Email и Пароль
  Future<void> _reauthenticateWithEmailPassword(User user) async {
    try {
      final email = user.email;
      if (email == null)
        throw FirebaseAuthException(
          code: "no-email",
          message: "Email не найден",
        );

      final passwordController = TextEditingController();

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Введите пароль'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Ваш пароль"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    final password = passwordController.text.trim();
                    Navigator.pop(context);

                    final credential = EmailAuthProvider.credential(
                      email: email,
                      password: password,
                    );

                    await user.reauthenticateWithCredential(credential);
                    print("Реаутентификация через Email прошла успешно!");
                  },
                  child: Text('Подтвердить'),
                ),
              ],
            ),
      );
    } catch (e) {
      print("Ошибка реаутентификации: $e");
    }
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    try {
      await GoogleSignIn().signOut(); // Очистить предыдущие учетные данные
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Если пользователь отменил вход

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      print("✅ Реаутентификация через Google прошла успешно!");
    } catch (e) {
      print("❌ Ошибка реаутентификации через Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) =>
      isEmailVerified
          ? HomeScreen()
          : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('E-mail verification')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Message has been sent to your email. Please verify your email address.',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: canResendEmail ? sendVerificationEmail : null,
                      icon: const Icon(Icons.email),
                      label: const Text('Resend email'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        timer?.cancel();
                        await reauthenticateAndDelete();
                      },
                      child: const Text(
                        'Delete account',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
}
