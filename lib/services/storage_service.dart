import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _themeKey = 'app_theme';
  static const String _localeKey = 'app_locale';
  static const _apiKeyKey = 'user_api_key';
  static const _providerKey = 'ai_provider';
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_themeKey, mode.toString());
  }

  static Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey) ?? ThemeMode.system.toString();

    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeStr,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_localeKey) ?? 'en';
    return Locale(lang);
  }

  static Future<String> loadLocaleString() async {
    final prefs = await SharedPreferences.getInstance();
    final String localeCode = prefs.getString(_localeKey) ?? 'en';
    if (localeCode == 'en') {
      return 'english';
    } else if (localeCode == 'zh') {
      return 'mandarin';
    } else {
      return 'english'; // Default
    }
  }

  static Future<void> saveFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('reminder_frequency', frequency);
  }

  static Future<String> loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminder_frequency') ?? 'daily';
  }

  // 💼 Save AI Provider (e.g., OpenAI, OpenRouter)
  static Future<void> saveProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider);
  }

  // 💼 Load AI Provider
  static Future<String?> loadProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_providerKey);
  }

  static Future<void> saveApiKey(String key) async {
    await _secureStorage.write(key: _apiKeyKey, value: key);
  }

  static Future<String?> loadApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }
}
