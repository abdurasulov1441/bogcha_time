import 'package:bogcha_time/app/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleNavigation());
  }

  Future<void> _handleNavigation() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // ✅ Если пользователь авторизован → Сад
      return _navigateToGardenScreen();
    }

    // 🔹 Проверяем кеш
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uuid = prefs.getString('uuid');

    if (uuid != null) {
      // ✅ Если есть кеш → Родитель
      return _navigateToParentScreen();
    }

    // ❌ Нет данных → Выбор роли
    return _navigateToSelectRole();
  }

  void _navigateToGardenScreen() {
    if (mounted) context.go(Routes.gardenPage);
  }

  void _navigateToParentScreen() {
    if (mounted) context.go(Routes.parentsPage);
  }

  void _navigateToSelectRole() {
    if (mounted) context.go(Routes.roleSelectPage);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
