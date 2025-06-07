import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _themeKey = 'app_theme';
  static const String _localeKey = 'app_locale';

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
}
