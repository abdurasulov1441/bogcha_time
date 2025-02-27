import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedCode;
  bool isFlashOn = false;
  bool isFrontCamera = false;

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

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });

    qrController.scannedDataStream.listen((scanData) {
      setState(() {
        scannedCode = scanData.code;
      });
      if (scannedCode != null) {
        _showResultDialog(scannedCode!);
      }
    });
  }

  void _showResultDialog(String code) {
    controller?.pauseCamera();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("QR Kod skanerlandi!"),
        content: Text("Kod: $code"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller?.resumeCamera();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
        title:  Text('QR Kodni skaner qilish', style: AppStyle.fontStyle.copyWith(color: AppColors.textColor,fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
     
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:  AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                 
                    
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNeumorphicButton(
                        icon: isFlashOn ? Icons.flash_off : Icons.flash_on,
                        label: "",
                        onTap: () async {
                          await controller?.toggleFlash();
                          setState(() {
                            isFlashOn = !isFlashOn;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildNeumorphicButton(
                        icon: isFrontCamera ? Icons.camera_rear : Icons.camera_front,
                        label: "Kamerani almashtirish",
                        onTap: () async {
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
          ),
        ],
      ),
    );
  }


  Widget _buildNeumorphicButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(4, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF3D8D7A)),
            if(label=="")const SizedBox() else const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF3D8D7A))),
          ],
        ),
      ),
    );
  }
}
