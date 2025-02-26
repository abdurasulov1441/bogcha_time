import 'package:easy_localization/easy_localization.dart';
import 'package:bogcha_time/app/app.dart';
import 'package:bogcha_time/common/db/cache/cache.dart';
import 'package:bogcha_time/common/db/cache/prefs_cache.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global cache obyekti
late final Cache cache;

/// Cache'ni boshlang‘ich qiymatga ega qilish
Future<void> initializeCache() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    cache = PrefsCache(prefs);
  } catch (e) {
    print("Cache yuklashda xatolik: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase yuklash
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase yuklashda xatolik: $e");
  }

  // Cache yuklash
  await initializeCache();

  // Ekran yo‘nalishini bloklash (Faqat portret)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // EasyLocalization konfiguratsiyasi
  EasyLocalization.logger.enableBuildModes = [];
  try {
    await EasyLocalization.ensureInitialized();
  } catch (e) {
    print("EasyLocalization yuklashda xatolik: $e");
  }

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      startLocale: const Locale('uz'),
      child: const App(),
    ),
  );
}
