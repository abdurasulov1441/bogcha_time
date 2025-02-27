import 'package:easy_localization/easy_localization.dart';
import 'package:bogcha_time/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bogcha_time/app/router.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Фоновое сообщение: ${message.notification?.title}");
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _setupLocalNotifications();
  }

  /// Firebase bildirishnomalarini sozlash
  Future<void> _setupFirebaseMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Пользователь разрешил уведомления.');

      String? token = await messaging.getToken();
      debugPrint("FCM Token: $token");

      cache.setString('fcm_token', '$token'); 

      setState(() {});

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'Получено сообщение в активном состоянии: ${message.notification?.title}',
        );

        _showLocalNotification(
          title: message.notification?.title ?? 'Yangi xabar',
          body: message.notification?.body ?? 'Нет описания',
        );
      });

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } else {
      debugPrint('Пользователь не разрешил уведомления.');
    }
  }

  /// Lokal bildirishnomalarni sozlash
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  /// Lokal bildirishnoma ko‘rsatish
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'default_channel_id',
          'Основной канал',
          channelDescription:
              'Этот канал используется для основных уведомлений',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _localNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Bog'cha Time",
      routerConfig: router,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
    );
  }
}
