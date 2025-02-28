import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LinkChildPage extends StatefulWidget {
  const LinkChildPage({super.key});

  @override
  _LinkChildPageState createState() => _LinkChildPageState();
}

class _LinkChildPageState extends State<LinkChildPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _linkChild(String code) async {
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Kodni kiriting!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 🔹 Найти детский сад, в котором зарегистрирован ребенок
      QuerySnapshot gardenQuery = await firestore
          .collection('garden')
          .where('children', arrayContains: code)
          .limit(1)
          .get();

      if (gardenQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = '❌ Xatolik: Bog‘cha ID’si topilmadi! Admin bilan bog‘laning.';
        });
        return;
      }

      DocumentSnapshot gardenDoc = gardenQuery.docs.first;
      String gardenId = gardenDoc.id;

      // 🔹 Найти ребенка в этом садике
      QuerySnapshot childQuery = await firestore
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .where('unique_code', isEqualTo: code)
          .limit(1)
          .get();

      if (childQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = '❌ Xatolik: Bola topilmadi! QR kodni tekshiring.';
        });
        return;
      }

      DocumentSnapshot childDoc = childQuery.docs.first;
      Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
      String childId = childDoc.id;
      String? parentId = childData['parent_id'];

      // 🔹 Генерация FCM-токена
      String? fcmToken = await messaging.getToken();

      if (parentId == null) {
        // ✅ Если у ребенка нет родителя, создаем нового
        parentId = const Uuid().v4();

        await firestore.collection('parents').doc(parentId).set({
          'parent_id': parentId,
          'parent_name': "Ismingizni kiriting",
          'parent_surname': "Familiyangizni kiriting",
          'parent_phone': "Telefon raqam",
          'fcm_token': fcmToken,
          'linked_children': [childId],
          'created_at': FieldValue.serverTimestamp(),
        });

        // 🔹 Обновляем `parent_id` у ребенка
        await childDoc.reference.update({'parent_id': parentId});
      } else {
        // ✅ Если `parent_id` уже есть, добавляем ребенка в `linked_children`
        DocumentReference parentRef = firestore.collection('parents').doc(parentId);
        await parentRef.update({
          'linked_children': FieldValue.arrayUnion([childId]),
        });
      }

      // 🔹 Сохраняем `parent_id`, `child_id`, `garden_id` в кеш
      await prefs.setString('parent_id', parentId);
      await prefs.setString('child_id', childId);
      await prefs.setString('garden_id', gardenId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Bola muvaffaqiyatli bog‘landi!")),
      );

      // ✅ Перенаправляем в кабинет родителя
      context.go(Routes.parentsPage);
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Xatolik: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Bola bog‘lash',
          style: AppStyle.fontStyle.copyWith(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Kod kiriting yoki QR kodni skaner qiling',
                style: AppStyle.fontStyle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            NeumorphicTextField(
              controller: _codeController,
              hintText: 'Kod kiriting',
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              text: "Bola bog‘lash",
              isDisabled: _isLoading,
              onPressed: () => _linkChild(_codeController.text.trim()),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const Spacer(),
            NeumorphicButton(
              text: "📷 QR kodni skaner qilish",
              onPressed: () => context.push(Routes.qrCodePage),
            ),
          ],
        ),
      ),
    );
  }
}
