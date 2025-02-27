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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  Future<void> _checkUserRole() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      _navigateToSelectRole();
      return;
    }

    final String uid = user.uid;

    try {
      // 🔹 1️⃣ Ota-onani farzand orqali tekshiramiz
      final childrenQuery = await _firestore
          .collection('children')
          .where('parent_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (childrenQuery.docs.isNotEmpty) {
        _navigateToParentScreen();
        return;
      }

  
      final gardenDoc = await _firestore.collection('garden').doc(uid).get();

      if (gardenDoc.exists) {
        _navigateToGardenScreen();
        return;
      }


      _navigateToQRScan();
    } catch (e) {
      debugPrint('❌ Xatolik yuz berdi: $e');
      _navigateToSelectRole();
    }
  }

  void _navigateToParentScreen() {
    if (mounted) context.go(Routes.parentsPage);
  }

  void _navigateToGardenScreen() {
    if (mounted) context.go(Routes.gardenPage);
  }

  void _navigateToQRScan() {
    if (mounted) context.go(Routes.qrCodePage);
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
