import 'package:flutter/material.dart';

import 'package:bytecards/theme_manager.dart';
import 'package:bytecards/locale_manager.dart';
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
    _selectedFrequency = "Daily"; // Provide sensible defaults
    _selectedLanguage = "English";
    _selectedAppTheme = "Light";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedFrequency = AppLocalizations.of(context)!.daily;
        _selectedLanguage = AppLocalizations.of(context)!.english;
        _selectedAppTheme = AppLocalizations.of(context)!.light;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          _buildSettingsTile(
            title: AppLocalizations.of(context)!.reminderFrequency,
            subtitle: _selectedFrequency,
            icon: Icons.notifications,
            onTap: () {
              _showFrequencyDialog(context);
            },
          ),
          _buildSettingsTile(
            title: AppLocalizations.of(context)!.language,
            subtitle: _selectedLanguage,
            icon: Icons.language,
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildSettingsTile(
            title: AppLocalizations.of(context)!.appTheme,
            subtitle: _selectedAppTheme,
            icon: Icons.palette,
            onTap: () {
              _showThemeDialog(context);
            },
          ),
        ],
      ),
    );
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
        setState(() {
          switch (settingType) {
            case SettingType.reminderFrequency:
              _selectedFrequency = option;
              break;
            case SettingType.language:
              _selectedLanguage = option;
              if (option == AppLocalizations.of(context)!.english) {
                localeNotifier.value = const Locale('en');
                StorageService.saveLocale(const Locale('en'));
              } else if (option == AppLocalizations.of(context)!.mandarin) {
                localeNotifier.value = const Locale('zh');
                StorageService.saveLocale(const Locale('zh'));
              }
              break;
            case SettingType.appTheme:
              _selectedAppTheme = option;
              if (option == AppLocalizations.of(context)!.light) {
                themeNotifier.value = ThemeMode.light;
                StorageService.saveTheme(ThemeMode.light);
              } else if (option == AppLocalizations.of(context)!.dark) {
                themeNotifier.value = ThemeMode.dark;
                StorageService.saveTheme(ThemeMode.dark);
              } else {
                themeNotifier.value = ThemeMode.system;
                StorageService.saveTheme(ThemeMode.system);
              }
              break;
          }
        });
        Navigator.pop(context);
      },
    );
  }
}
