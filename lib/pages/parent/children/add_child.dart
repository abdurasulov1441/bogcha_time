import 'dart:convert';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddChildQRPage extends StatefulWidget {
  const AddChildQRPage({super.key});

  @override
  _AddChildQRPageState createState() => _AddChildQRPageState();
}

class _AddChildQRPageState extends State<AddChildQRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Kameraga ruxsat kerak!')),
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

      Map<String, dynamic> qrInfo;
      try {
        qrInfo = jsonDecode(qrData);
      } catch (e) {
        setState(() {
          _errorMessage = "❌ QR kod noto‘g‘ri!";
        });
        return;
      }

      String? gardenId = qrInfo["garden_id"];
      String? uniqueCode = qrInfo["unique_code"];

      if (gardenId == null || uniqueCode == null) {
        setState(() {
          _errorMessage = "❌ QR kodda noto‘g‘ri ma'lumot!";
        });
        return;
      }

      // ✅ Ota-ona ID-ni cache-dan olish
      String? parentId = prefs.getString('parent_id');
      if (parentId == null) {
        setState(() {
          _errorMessage = '❌ Xatolik: Ota-ona aniqlanmadi!';
        });
        return;
      }

      // ✅ Farzandni aniqlash
      QuerySnapshot childQuery = await firestore
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .where('unique_code', isEqualTo: uniqueCode)
          .limit(1)
          .get();

      if (childQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = '❌ Xatolik: Bola topilmadi!';
        });
        return;
      }

      DocumentSnapshot childDoc = childQuery.docs.first;
      String childId = childDoc.id;

      // ✅ Ota-onaga farzandni bog‘lash
      await firestore.collection('parents').doc(parentId).update({
        'linked_children': FieldValue.arrayUnion([childId]),
      });

      // ✅ Cache'ni yangilash
      await prefs.setString('child_id', childId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Yangi bola muvaffaqiyatli bog‘landi!")),
      );

      // ✅ Ota-ona sahifasiga qaytish
      context.go(Routes.parentsPage);
    } catch (e) {
      setState(() {
        _errorMessage = "❌ Xatolik: $e";
      });
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
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(3, 3),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Farzandingizni bog‘lash uchun QR kodni skaner qiling",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isProcessing) const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
