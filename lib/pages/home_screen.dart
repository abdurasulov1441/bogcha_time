import 'package:bogcha_time/app/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _checkUserRole() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      _navigateToSelectRole();
      return;
    }

    final String uid = user.uid;

    try {
      final parentsDoc = await _firestore.collection('parents').doc(uid).get();

      if (parentsDoc.exists) {
        _navigateToParentScreen();
        return;
      }
      final gardenDoc = await _firestore.collection('garden').doc(uid).get();

      if (gardenDoc.exists) {
        _navigateToGardenScreen();
        return;
      }

      _navigateToSelectRole();
    } catch (e) {
      debugPrint('Ошибка при проверке роли: $e');
      _navigateToSelectRole();
    }
  }

  void _navigateToParentScreen() {
 context.go(Routes.parentsPage);
  }

  void _navigateToGardenScreen() {
  context.go(Routes.gardenPage);
  }

  
  void _navigateToSelectRole() {
    context.go(Routes.roleSelectPage);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
