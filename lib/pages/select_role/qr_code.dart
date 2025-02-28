import 'dart:convert';
import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kameraga ruxsat kerak!')),
      );
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });

    qrController.scannedDataStream.listen((scanData) {
      if (!_isProcessing) {
        _isProcessing = true;
        _handleScannedCode(scanData.code!);
      }
    });
  }

  Future<void> _handleScannedCode(String qrData) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 📌 🔍 Разбираем JSON-данные из QR-кода
      Map<String, dynamic> qrInfo;
      try {
        qrInfo = jsonDecode(qrData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ QR kod noto‘g‘ri!")),
        );
        return;
      }

      String? gardenId = qrInfo["garden_id"];
      String? uniqueCode = qrInfo["unique_code"];

      if (gardenId == null || uniqueCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ QR kodda noto‘g‘ri ma'lumot!")),
        );
        return;
      }

      // 🔹 Найти ребенка в указанном детском саду
      QuerySnapshot childQuery = await firestore
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .where('unique_code', isEqualTo: uniqueCode)
          .limit(1)
          .get();

      if (childQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Xatolik: Bola topilmadi! QR kodni tekshiring.")),
        );
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
          'fcm_tokens': [fcmToken], // 🔹 Создаем список токенов
          'linked_children': [childId],
          'created_at': FieldValue.serverTimestamp(),
        });

        // 🔹 Обновляем `parent_id` у ребенка
        await childDoc.reference.update({'parent_id': parentId});
      } else {
        // ✅ Если `parent_id` уже есть, добавляем ребенка в `linked_children`
        DocumentReference parentRef = firestore.collection('parents').doc(parentId);

        DocumentSnapshot parentDoc = await parentRef.get();
        List<String> existingTokens = [];

        // ✅ Проверяем, существует ли поле `fcm_tokens`
        if (parentDoc.exists && parentDoc.data() != null) {
          var data = parentDoc.data() as Map<String, dynamic>;
          if (data.containsKey("fcm_tokens")) {
            existingTokens = List<String>.from(data["fcm_tokens"]);
          }
        }

        if (!existingTokens.contains(fcmToken)) {
          existingTokens.add(fcmToken!);
        }

        await parentRef.update({
          'linked_children': FieldValue.arrayUnion([childId]),
          'fcm_tokens': existingTokens, // 🔹 Обновляем список FCM-токенов
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Xatolik: $e")));
    } finally {
      setState(() {
        _isProcessing = false;
      });
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'QR Kodni skaner qilish',
          style: AppStyle.fontStyle.copyWith(color: AppColors.textColor, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) const CircularProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(isFrontCamera ? Icons.camera_rear : Icons.camera_front),
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {
                          isFrontCamera = !isFrontCamera;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
