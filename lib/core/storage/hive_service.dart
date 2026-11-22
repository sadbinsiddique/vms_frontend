import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

/// Centralized local storage service using Hive with in-memory fallback for headless/test environments.
class HiveService {
  static const String appBoxName = 'vms_storage';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._fallback();

  final Box? _box;
  final Map<String, dynamic> _memoryFallback;

  HiveService._(this._box) : _memoryFallback = {};
  HiveService._fallback() : _box = null, _memoryFallback = {};

  static Future<HiveService> init() async {
    try {
      await Hive.initFlutter();
      final box = await Hive.openBox(appBoxName);
      _instance = HiveService._(box);
    } catch (_) {
      _instance = HiveService._fallback();
    }
    return _instance!;
  }

  String? getAuthToken() {
    if (_box != null && _box.isOpen) {
      return _box.get(tokenKey) as String?;
    }
    return _memoryFallback[tokenKey] as String?;
  }

  Future<void> setAuthToken(String token) async {
    if (_box != null && _box.isOpen) {
      await _box.put(tokenKey, token);
    } else {
      _memoryFallback[tokenKey] = token;
    }
  }

  Future<void> removeAuthToken() async {
    if (_box != null && _box.isOpen) {
      await _box.delete(tokenKey);
    } else {
      _memoryFallback.remove(tokenKey);
    }
  }

  UserModel? getUser() {
    dynamic raw;
    if (_box != null && _box.isOpen) {
      raw = _box.get(userKey);
    } else {
      raw = _memoryFallback[userKey];
    }
    if (raw == null) return null;
    try {
      if (raw is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(raw));
      } else if (raw is String) {
        return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> setUser(UserModel user) async {
    final encoded = jsonEncode(user.toJson());
    if (_box != null && _box.isOpen) {
      await _box.put(userKey, encoded);
    } else {
      _memoryFallback[userKey] = encoded;
    }
  }

  Future<void> removeUser() async {
    if (_box != null && _box.isOpen) {
      await _box.delete(userKey);
    } else {
      _memoryFallback.remove(userKey);
    }
  }

  bool get isAuthenticated => getAuthToken() != null && getAuthToken()!.isNotEmpty;

  Future<void> clearAll() async {
    if (_box != null && _box.isOpen) {
      await _box.clear();
    }
    _memoryFallback.clear();
  }
}
