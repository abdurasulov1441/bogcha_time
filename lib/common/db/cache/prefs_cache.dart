import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cache.dart';

final class PrefsCache extends Cache {
  final SharedPreferences _prefs;

  PrefsCache(this._prefs);

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  Map<String, dynamic>? getMap(String key) {
    try {
      final value = _prefs.getString(key);
      return jsonDecode(value!);
    } catch (_) {
      return null;
    }
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
    await _prefs.reload();
  }
}
