import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
  

    await FirebaseAuth.instance.signOut();

   context.go(Routes.home);

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          onPressed: () {
            context.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Open shopping cart',
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ваш Email: ${user?.email}', style: AppStyle.fontStyle),
            TextButton(
              onPressed: () => signOut(),
              child: const Text('Выйти', style: AppStyle.fontStyle),
            ),
          ],
        ),
      ),
    );
  }
}
