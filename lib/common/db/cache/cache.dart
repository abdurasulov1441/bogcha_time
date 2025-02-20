abstract class Cache {
  String? getString(String key);

  Future<void> setString(String key, String value);

  bool? getBool(String key);

  Future<void> setBool(String key, bool value);

  int? getInt(String key);

  Future<void> setInt(String key, int value);

  double? getDouble(String key);

  Future<void> setDouble(String key, double value);

  List<String>? getStringList(String key);

  Future<void> setStringList(String key, List<String> value);

  Map<String, dynamic>? getMap(String key);

  Future<void> setMap(String key, Map<String, dynamic> value);

  Future<void> remove(String key);

  Future<void> clear();

 


}
