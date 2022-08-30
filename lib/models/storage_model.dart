import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static final SecureStorage _secureStorage = SecureStorage._interal();

  late FlutterSecureStorage flutterSecureStorage;

  factory SecureStorage() {
    return _secureStorage;
  }

  // 초기화
  SecureStorage._interal() {
    _create();
  }

  //
  void _create() async {
    flutterSecureStorage = const FlutterSecureStorage();
  }

  Future<String?> read(String key) async {
    return await flutterSecureStorage.read(key: key);
  }

  void write(String key, String value) {
    flutterSecureStorage.write(key: key, value: value);
  }

  void delete(String key) {
    flutterSecureStorage.delete(key: key);
  }

  void deleteAll() {
    flutterSecureStorage.deleteAll();
  }

  FlutterSecureStorage getFlutterSecureStorage() {
    return flutterSecureStorage;
  }
}

class SharedStorage {
  
  static Future<void> write(String key, var values) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    switch (values.runtimeType.toString()) {
      case "int":
        sharedPreferences.setInt(key, values);
        break;
      case "String":
        sharedPreferences.setString(key, values);
        break;
      case "double":
        sharedPreferences.setDouble(key, values);
        break;
      case "Bool":
        sharedPreferences.setBool(key, values);
        break;
      case "List":
        sharedPreferences.setStringList(key, values);
        break;
    }
  }

  static Future<int?> readToInt(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(key);
  }

  static Future<String?> readToString(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  static Future<double?> readToDouble(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble(key);
  }

  static Future<bool?> readToBool(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(key);
  }

  static Future<List<String>?> readList(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(key);
  }

  static Future<void> delete(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(key);
  }

  static Future<void> deleteAll() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
