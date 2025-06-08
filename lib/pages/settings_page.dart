import 'package:flutter/material.dart';

import 'package:bytecards/theme_manager.dart';
import 'package:bytecards/locale_manager.dart';
import 'package:bytecards/frequency_manager.dart';
import 'package:bytecards/enum/setting_type.dart';
import 'package:bytecards/l10n/generated/app_localizations.dart';
import 'package:bytecards/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedFrequency;
  late String _selectedLanguage;
  late String _selectedAppTheme;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = ""; // Initialize with empty strings
    _selectedLanguage = "";
    _selectedAppTheme = "";
  }

  Future<void> _loadSettings(BuildContext context) async {
    // Load settings from storage here, if available
    String? storedFrequency = await StorageService.loadFrequency();
    String? storedLanguage = await StorageService.loadLocaleString();
    ThemeMode? storedTheme = await StorageService.loadTheme();

    _selectedFrequency = storedFrequency;
    _selectedLanguage = storedLanguage;

    if (storedTheme == ThemeMode.light) {
      _selectedAppTheme = 'light';
    } else if (storedTheme == ThemeMode.dark) {
      _selectedAppTheme = 'dark';
    } else {
      _selectedAppTheme = 'systemDefault';
    }
    themeNotifier.value = storedTheme; // Apply the stored theme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: FutureBuilder(
        future: _loadSettings(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              children: [
                _buildSettingsTile(
                  title: AppLocalizations.of(context)!.reminderFrequency,
                  subtitle: _getLocalizedLanguage(
                    _selectedFrequency,
                    context,
                  ), // Localize here
                  icon: Icons.notifications,
                  onTap: () {
                    _showFrequencyDialog(context);
                  },
                ),
                _buildSettingsTile(
                  title: AppLocalizations.of(context)!.language,
                  subtitle: _getLocalizedLanguage(
                    _selectedLanguage,
                    context,
                  ), // Localize here
                  icon: Icons.language,
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
                _buildSettingsTile(
                  title: AppLocalizations.of(context)!.appTheme,
                  subtitle: _getLocalizedLanguage(
                    _selectedAppTheme,
                    context,
                  ), // Localize here
                  icon: Icons.palette,
                  onTap: () {
                    _showThemeDialog(context);
                  },
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Show a loading indicator
          }
        },
      ),
    );
  }

  String _getLocalizedLanguage(String key, BuildContext context) {
    switch (key) {
      case 'english':
        return AppLocalizations.of(context)!.english;
      case 'mandarin':
        return AppLocalizations.of(context)!.mandarin;
      case 'light':
        return AppLocalizations.of(context)!.light;
      case 'dark':
        return AppLocalizations.of(context)!.dark;
      case 'systemDefault':
        return AppLocalizations.of(context)!.systemDefault;
      case 'daily':
        return AppLocalizations.of(context)!.daily;
      case 'weekly':
        return AppLocalizations.of(context)!.weekly;
      case 'monthly':
        return AppLocalizations.of(context)!.monthly;
      default:
        return '';
    }
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.reminderFrequency),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(
                context,
                AppLocalizations.of(context)!.daily,
                SettingType.reminderFrequency,
              ),
              _dialogOption(
                context,
                AppLocalizations.of(context)!.weekly,
                SettingType.reminderFrequency,
              ),
              _dialogOption(
                context,
                AppLocalizations.of(context)!.monthly,
                SettingType.reminderFrequency,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(
                context,
                AppLocalizations.of(context)!.english,
                SettingType.language,
              ),
              _dialogOption(
                context,
                AppLocalizations.of(context)!.mandarin,
                SettingType.language,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(
                context,
                AppLocalizations.of(context)!.light,
                SettingType.appTheme,
              ),
              _dialogOption(
                context,
                AppLocalizations.of(context)!.dark,
                SettingType.appTheme,
              ),
              _dialogOption(
                context,
                AppLocalizations.of(context)!.systemDefault,
                SettingType.appTheme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogOption(
    BuildContext context,
    String option,
    SettingType settingType,
  ) {
    return ListTile(
      title: Text(option),
      onTap: () {
        switch (settingType) {
          case SettingType.reminderFrequency:
            if (option == AppLocalizations.of(context)!.daily) {
              frequencyNotifier.value = const Frequency('daily');
              StorageService.saveFrequency('daily');
              _selectedFrequency = 'daily'; // ✅ Store key
            } else if (option == AppLocalizations.of(context)!.weekly) {
              frequencyNotifier.value = const Frequency('weekly');
              StorageService.saveFrequency('weekly');
              _selectedFrequency = 'weekly'; // ✅ Store key
            } else if (option == AppLocalizations.of(context)!.monthly) {
              frequencyNotifier.value = const Frequency('monthly');
              StorageService.saveFrequency('monthly');
              _selectedFrequency = 'monthly'; // ✅ Store key
            }
            setState(() {});
            break;
          case SettingType.language:
            if (option == AppLocalizations.of(context)!.english) {
              localeNotifier.value = const Locale('en');
              StorageService.saveLocale(const Locale('en'));
              _selectedLanguage = 'english'; // ✅ Store key
            } else if (option == AppLocalizations.of(context)!.mandarin) {
              localeNotifier.value = const Locale('zh');
              StorageService.saveLocale(const Locale('zh'));
              _selectedLanguage = 'mandarin'; // ✅ Store key
            }
            setState(() {});
            break;
          case SettingType.appTheme:
            if (option == AppLocalizations.of(context)!.light) {
              themeNotifier.value = ThemeMode.light;
              StorageService.saveTheme(ThemeMode.light);
              _selectedAppTheme = 'light'; // ✅ Store key
            } else if (option == AppLocalizations.of(context)!.dark) {
              themeNotifier.value = ThemeMode.dark;
              StorageService.saveTheme(ThemeMode.dark);
              _selectedAppTheme = 'dark'; // ✅ Store key
            } else if (option == AppLocalizations.of(context)!.systemDefault) {
              themeNotifier.value = ThemeMode.system;
              StorageService.saveTheme(ThemeMode.system);
              _selectedAppTheme = 'systemDefault'; // ✅ Store key
            }
            setState(() {});
            break;
        }
        Navigator.pop(context);
      },
    );
  }
}
