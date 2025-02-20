import 'package:bogcha_time/common/services/firebase_streem.dart';
import 'package:bogcha_time/pages/auth/login_screen.dart';
import 'package:bogcha_time/pages/auth/reset_password_screen.dart';
import 'package:bogcha_time/pages/auth/signup_screen.dart';
import 'package:bogcha_time/pages/home_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const firebaseStream = '/firebaseStream';
  static const home = '/home';
  static const loginPage = '/loginPage';
  static const resetPasswordPage = '/resetPasswordPage';
  static const signUpPage = '/signUpPage';
}

String _initialLocation() {
  return Routes.firebaseStream;
}

Object? _initialExtra() {
  return Routes.home;
}

final router = GoRouter(
  initialLocation: _initialLocation(),
  initialExtra: _initialExtra(),
  routes: [
    GoRoute(
      path: Routes.firebaseStream,
      builder: (context, state) {
        return const FirebaseStream();
      },
    ),
    GoRoute(
      path: Routes.loginPage,
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen();
      },
    ),
    GoRoute(
      path: Routes.resetPasswordPage,
      builder: (context, state) {
        return ResetPasswordScreen();
      },
    ),
    GoRoute(
      path: Routes.signUpPage,
      builder: (context, state) {
        return SignUpScreen();
      },
    ),
  ],
);
