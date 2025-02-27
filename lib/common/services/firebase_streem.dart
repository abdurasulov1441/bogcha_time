// import 'package:bogcha_time/pages/auth/login_screen.dart';
// import 'package:bogcha_time/pages/home_screen.dart';
// import 'package:bogcha_time/pages/auth/verify_email_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class FirebaseStream extends StatelessWidget {
//   const FirebaseStream({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Scaffold(
//             body: Center(child: Text('Error something by hacker!')),
//           );
//         } else if (snapshot.hasData) {
//           if (!snapshot.data!.emailVerified) {
//             return const VerifyEmailScreen();
//           }
//           return HomeScreen();
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
