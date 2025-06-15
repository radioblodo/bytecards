import 'package:bytecards/frequency_manager.dart';
import 'package:flutter/material.dart';
import 'services/storage_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bytecards/services/notification_service.dart';
import 'theme_manager.dart';
import 'locale_manager.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready

  await NotificationService.init();

  await NotificationService.requestNotificationPermissions();
  await NotificationService.checkAndRequestExactAlarmPermission(); // Call this here too

  // Load persisted theme and locale
  themeNotifier.value = await StorageService.loadTheme();
  localeNotifier.value = await StorageService.loadLocale();
  frequencyNotifier.value = Frequency.fromString(
    await StorageService.loadFrequency(),
  );

  runApp(const ByteCardsApp());
}
