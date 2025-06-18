import 'dart:convert';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _preferences;

  /// Inisialisasi SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Simpan token ke SharedPreferences
  static Future<bool> saveToken(String token) async {
    return await _preferences?.setString('token', token) ?? false;
  }

  /// Ambil token dari SharedPreferences
  static String? getToken() {
    return _preferences?.getString('token');
  }

  /// Simpan credentials ke SharedPreferences
  static Future<void> saveCredentials(User credentials) async {
    final String credentialsJson = jsonEncode(credentials.toJson());
    await _preferences?.setString('credentials', credentialsJson);
  }

  /// Ambil credentials dari SharedPreferences
  static User? getCredentials() {
    final String? credentialsString = _preferences?.getString('credentials');
    if (credentialsString != null) {
      final Map<String, dynamic> json = jsonDecode(credentialsString);
      return User.fromJson(json);
    }
    return null;
  }

  /// Hapus credentials dari SharedPreferences
  static Future<void> clearCredentials() async {
    await _preferences?.remove('credentials');
  }

  /// Hapus token dari SharedPreferences
  static Future<void> clearToken() async {
    await _preferences?.remove('token');
  }

  /// Hapus cache movie dari SharedPreferences
  static Future<void> clearMovieCache() async {
    await _preferences?.remove('cached_movies');
  }
}
