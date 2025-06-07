import 'package:flutter/material.dart';
import 'services/storage_service.dart';

import 'theme_manager.dart';
import 'locale_manager.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready

  // Load persisted theme and locale
  themeNotifier.value = await StorageService.loadTheme();
  localeNotifier.value = await StorageService.loadLocale();

  runApp(const ByteCardsApp());
}
