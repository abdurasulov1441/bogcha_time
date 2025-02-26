// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';


// class VerificationScreen extends StatefulWidget {
//   final String phoneNumber;

//   const VerificationScreen({super.key, required this.phoneNumber});

//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final TextEditingController _smsController = TextEditingController();

//   late PinTheme currentPinTheme;
//   bool isLoading = false;

//   final String fcm = cache.getString('fcm_token') ?? '';

//   OtpTimerButtonController controller = OtpTimerButtonController();

//   @override
//   void initState() {
//     super.initState();
//     _startUserConsentListener();
//     currentPinTheme = defaultPinTheme;
//   }

//   @override
//   void dispose() {
//     _smsController.dispose();
//     super.dispose();
//   }

//   void _onCodeChanged(String value) {
//     setState(() {
//       currentPinTheme = defaultPinTheme;
//     });
//   }

//   Future<void> _startUserConsentListener() async {
//     final smartAuth = SmartAuth.instance;

//     try {
//       final res = await smartAuth.getSmsWithUserConsentApi();

//       if (res.hasData) {
//         final fullMessage = res.requireData.sms;
//         debugPrint('Full Message: $fullMessage');

//         final code = extractCode(fullMessage);
//         if (code != null) {
//           debugPrint('Extracted Code: $code');
//           setState(() {
//             _smsController.text = code;
//           });
//           _verifyCode();
//         } else {
//           debugPrint('Code not found in SMS.');
//         }
//       } else if (res.isCanceled) {
//         debugPrint('User canceled the consent dialog.');
//       } else {
//         debugPrint('Sms User Consent API failed.');
//       }
//     } catch (e) {
//       debugPrint('Error using Sms User Consent API: $e');
//     }
//   }

//   String? extractCode(String message) {
//     final RegExp regExp = RegExp(r'\b\d{6}\b');
//     return regExp.stringMatch(message);
//   }

//   Future<void> _verifyCode() async {
//     String enteredCode = _smsController.text.trim();

//     if (enteredCode.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Tasdiqlash kodi 6 raqamdan iborat bo‘lishi kerak.'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await requestHelper.post(
//           '/services/zyber/api/auth/verify',
//           {
//             'phone_number': widget.phoneNumber,
//             'verification_code': enteredCode,
//             'fcm_token': fcm,
//           },
//           log: false);
//       print(fcm);
//       if (response['accessToken'] != null && response['refreshToken'] != null) {
//         cache.setString('user_token', response['accessToken']);
//         cache.setString('refresh_token', response['refreshToken']);
//         cache.setInt('user_id', response['id']);
//         cache.setInt('role_id', response['role_id']);
//         cache.setBool('isGPS', true);
//         cache.setBool('isNotification', true);
//         showSuccessToast(context, 'PayGo', 'verification_succes'.tr());
//         //delay after 1 second  context.go(Routes.homeScreen,);
//         await Future.delayed(const Duration(seconds: 1));
//         context.go(
//           Routes.homeScreen,
//         );
//       } else {
//         showErrorToast(context, 'PayGo', 'error_token'.tr());
//       }
//     } catch (e) {
//       showErrorToast(context, 'PayGo', e.toString());
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> resendVerificationCode(String phoneNumber) async {
//     try {
//       final response = await requestHelper.post(
//           '/services/zyber/api/auth/resend',
//           {'phone_number': phoneNumber.trim()},
//           log: false);

//       if (response['statusCode'] == 200 || response['statusCode'] == 201) {
//         String status = response['message'];
//         showSuccessToast(context, 'PayGo', status);
//       } else {
//         SnackBarService.showSnackBar(context, response['message'], false);
//       }
//     } catch (e) {
//       SnackBarService.showSnackBar(
//           context, 'Internetga ulanishda xatolik: $e', true);
//     }
//   }

//   final PinTheme focusedPinTheme = PinTheme(
//     width: 56,
//     height: 56,
//     textStyle: AppStyle.fontStyle.copyWith(
//         color: AppColors.backgroundColor, fontWeight: FontWeight.bold),
//     decoration: BoxDecoration(
//       color: const Color.fromARGB(68, 11, 97, 114),
//       shape: BoxShape.circle,
//     ),
//   );

//   final PinTheme defaultPinTheme = PinTheme(
//     width: 56,
//     height: 56,
//     textStyle: AppStyle.fontStyle.copyWith(color: AppColors.backgroundColor),
//     decoration: BoxDecoration(
//       color: Color.fromARGB(190, 11, 97, 114),
//       shape: BoxShape.circle,
//       // boxShadow: [
//       //   BoxShadow(
//       //     color: AppColors.grade1,
//       //     blurRadius: 10,
//       //     spreadRadius: 1,
//       //     offset: const Offset(0, 4),
//       //   ),
//       // ],
//     ),
//   );

//   final PinTheme errorPinTheme = PinTheme(
//     width: 56,
//     height: 56,
//     textStyle: const TextStyle(
//       fontSize: 20,
//       color: Colors.red,
//       fontWeight: FontWeight.w600,
//     ),
//     decoration: BoxDecoration(
//       color: Colors.red.shade100,
//       shape: BoxShape.circle,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.red.shade300,
//           blurRadius: 10,
//           spreadRadius: 1,
//           offset: const Offset(0, 4), // Тень вниз
//         ),
//       ],
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 200,
//               ),
//               Text(
//                 'enter_sms',
//                 style: AppStyle.fontStyle
//                     .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
//               ).tr(),
//               SizedBox(height: 10),
//               Text(
//                 'we_send_sms',
//                 style: AppStyle.fontStyle.copyWith(color: Colors.grey),
//               ).tr(),
//               SizedBox(height: 10),
//               Text(
//                 maskPhoneNumber(widget.phoneNumber),
//                 style: AppStyle.fontStyle.copyWith(color: AppColors.grade1),
//               ),
//               SizedBox(height: 20),
//               OtpTimerButton(
//                 controller: controller,
//                 height: 60,
//                 text: Text(
//                   'resend_code',
//                   style: AppStyle.fontStyle.copyWith(color: AppColors.grade1),
//                 ).tr(),
//                 duration: 60,
//                 radius: 30,
//                 backgroundColor: Colors.blue,
//                 textColor: Colors.white,
//                 buttonType: ButtonType.text_button,
//                 loadingIndicator: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.red,
//                 ),
//                 loadingIndicatorColor: Colors.red,
//                 onPressed: () {
//                   resendVerificationCode(widget.phoneNumber);
//                 },
//               ),
//               Pinput(
//                 length: 6,
//                 controller: _smsController,
//                 defaultPinTheme: defaultPinTheme,
//                 followingPinTheme: focusedPinTheme,
//                 errorPinTheme: errorPinTheme,
//                 onChanged: _onCodeChanged,
//                 onCompleted: (_) => _verifyCode(),
//               ),
//               SizedBox(height: 20),
//               isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _verifyCode,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.grade1,
//                         elevation: 5,
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text(
//                         'phone_verify',
//                         style: AppStyle.fontStyle
//                             .copyWith(color: AppColors.backgroundColor),
//                       ).tr(),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// final PinTheme followPinTheme = PinTheme(
//   width: 56,
//   height: 56,
//   textStyle: TextStyle(
//       fontSize: 20,
//       color: Color.fromRGBO(30, 60, 87, 1),
//       fontWeight: FontWeight.w600),
//   decoration: BoxDecoration(
//     border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
//     borderRadius: BorderRadius.circular(20),
//   ),
// );

// final PinTheme defaultPinTheme = PinTheme(
//   width: 56,
//   height: 56,
//   textStyle: TextStyle(
//       fontSize: 20,
//       color: Color.fromRGBO(30, 60, 87, 1),
//       fontWeight: FontWeight.w600),
//   decoration: BoxDecoration(
//     border: Border.all(color: Color.fromRGBO(77, 77, 77, 1)),
//     borderRadius: BorderRadius.circular(20),
//   ),
// );

// final PinTheme errorPinTheme = PinTheme(
//   width: 56,
//   height: 56,
//   textStyle: TextStyle(
//       fontSize: 20,
//       color: Color.fromRGBO(30, 60, 87, 1),
//       fontWeight: FontWeight.w600),
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.red),
//     borderRadius: BorderRadius.circular(20),
//   ),
// );

// final PinTheme successPinTheme = PinTheme(
//   width: 56,
//   height: 56,
//   textStyle: TextStyle(
//       fontSize: 20,
//       color: Color.fromRGBO(30, 60, 87, 1),
//       fontWeight: FontWeight.w600),
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.green),
//     borderRadius: BorderRadius.circular(20),
//   ),
// );

// String maskPhoneNumber(String phoneNumber) {
//   if (phoneNumber.length >= 11) {
//     return phoneNumber.replaceRange(9, 16, '******');
//   }
//   return phoneNumber;
// }
