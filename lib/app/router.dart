import 'package:bogcha_time/firebase_stream.dart';
import 'package:bogcha_time/pages/auth/login_screen.dart';
import 'package:bogcha_time/pages/garden/garden_main.dart';
import 'package:bogcha_time/pages/garden/children/add_child.dart';
import 'package:bogcha_time/pages/home_screen.dart';
import 'package:bogcha_time/pages/parent/parent_main.dart';
import 'package:bogcha_time/pages/select_role/instruction.dart';
import 'package:bogcha_time/pages/select_role/link_child_page.dart';
import 'package:bogcha_time/pages/select_role/qr_code.dart';
import 'package:bogcha_time/pages/select_role/select_role.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  /////////////////////////////////////////////////////////////////////
  static const home = '/home';
  static const firebaseStream = '/firebaseStream';
  static const loginPage = '/loginPage';
  static const resetPasswordPage = '/resetPasswordPage';

  static const linkChildPage = '/linkChildPage';
  static const qrCodePage = '/qrCodePage';
  static const qrInstruction = '/qrInstruction';


  static const smsVerify = '/smsVerify';

  /////////////////////////////////////////////////////////////////////
  static const roleSelectPage = '/roleSelectPage';
  /////////////////////////////////////////////////////////////////////

  static const gardenPage = '/gardenPage';


  /////////////////////////////////////////////////////////////////////

  static const parentsPage = '/parentsPage';
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
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen();
      },
    ),
    GoRoute(
      path: Routes.loginPage,
      builder: (context, state) {
        return LoginScreen();
      },
    ),
     GoRoute(
      path: Routes.firebaseStream,
      builder: (context, state) {
        return FirebaseStream();
      },
    ),
    GoRoute(
      path: Routes.roleSelectPage,
      builder: (context, state) {
        return RoleSelectionPage();
      },
    ),
    GoRoute(
      path: Routes.linkChildPage,
      builder: (context, state) {
        return LinkChildPage();
      },
    ),
     GoRoute(
      path: Routes.qrCodePage,
      builder: (context, state) {
        return QRScanScreen();
      },
    ),
    GoRoute(
      path: Routes.qrInstruction,
      builder: (context, state) {
        return ChildCodeInstructions();
      },
    ),
    GoRoute(
      path: Routes.gardenPage,
      builder: (context, state) {
        return GardenPage();
      },
    ),
    
    GoRoute(
      path: Routes.parentsPage,
      builder: (context, state) {
        return ParentsPage();
      },
    ),
  ],
);
