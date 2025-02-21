import 'package:bogcha_time/pages/garden/garden_home.dart';
import 'package:bogcha_time/pages/parent/parent_home.dart';
import 'package:bogcha_time/pages/select_role/select_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  /// **Проверяем, в какой коллекции есть пользователь**
  Future<void> _checkUserRole() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      _navigateToSelectRole();
      return;
    }

    final String uid = user.uid;

    try {
      // **Проверяем в коллекции `parents`**
      final parentsDoc = await _firestore.collection('parents').doc(uid).get();

      if (parentsDoc.exists) {
        _navigateToParentScreen();
        return;
      }

      // **Проверяем в коллекции `garden`**
      final gardenDoc = await _firestore.collection('garden').doc(uid).get();

      if (gardenDoc.exists) {
        _navigateToGardenScreen();
        return;
      }

      // **Если пользователь не найден, отправляем на выбор роли**
      _navigateToSelectRole();
    } catch (e) {
      debugPrint('Ошибка при проверке роли: $e');
      _navigateToSelectRole();
    }
  }

  /// **Переход на экран родителя**
  void _navigateToParentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParentHome()),
    );
  }

  /// **Переход на экран детского сада**
  void _navigateToGardenScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GardenHome()),
    );
  }

  /// **Переход на экран выбора роли**
  void _navigateToSelectRole() {
    // **Переход на экран выбора роли** как класс
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
