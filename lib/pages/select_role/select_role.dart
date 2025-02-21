import 'package:bogcha_time/pages/garden/garden_home.dart';
import 'package:bogcha_time/pages/parent/parent_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  _SelectRoleScreenState createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Функция сохранения роли в Firestore**
  Future<void> _saveRoleAndProceed() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Iltimos, rol tanlang!')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foydalanuvchi topilmadi!')),
        );
        return;
      }

      final String uid = user.uid;

      if (_selectedRole == 'parent') {
        await _firestore.collection('parents').doc(uid).set({
          'role': 'parent',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParentHome()),
        );
      } else if (_selectedRole == 'garden') {
        await _firestore.collection('garden').doc(uid).set({
          'role': 'garden',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GardenHome()),
        );
      }
    } catch (e) {
      debugPrint('Xatolik: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xatolik yuz berdi: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rolni tanlang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Iltimos, o'zingizning rolni tanlang:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// **Выбор "Родитель"**
            _buildRoleOption('Ota-Ona', 'parent'),

            /// **Выбор "Детский сад"**
            _buildRoleOption('Bog\'cha', 'garden'),

            const Spacer(),

            /// **Кнопка "Далее"**
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRoleAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Davom etish",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Виджет выбора роли**
  Widget _buildRoleOption(String title, String role) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              _selectedRole == role
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.white,
          border: Border.all(
            color: _selectedRole == role ? Colors.blue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              _selectedRole == role
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: _selectedRole == role ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
