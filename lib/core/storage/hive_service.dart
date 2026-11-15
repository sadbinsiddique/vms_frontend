import 'package:hive_flutter/hive_flutter.dart';

/// Centralized local storage service using Hive.
class HiveService {
  static const String appBoxName = 'vms_storage';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  static Future<HiveService> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(appBoxName);
    return HiveService._(box);
  }

  final Box _box;

  HiveService._(this._box);

  String? getAuthToken() {
    return _box.get(tokenKey) as String?;
  }

  Future<void> setAuthToken(String token) async {
    await _box.put(tokenKey, token);
  }

  Future<void> removeAuthToken() async {
    await _box.delete(tokenKey);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
