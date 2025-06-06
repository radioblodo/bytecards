import 'package:flutter/material.dart';
import 'package:bytecards/enum/setting_type.dart'; // ✅ Import the enum


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState(); 
}

class _SettingsPageState extends State<SettingsPage> {
  
  String _selectedFrequency = "Daily"; // store selected reminder frequency
  String _selectedLanguage = "English"; // store selected language 
  String _selectedAppTheme = "Light"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          _buildSettingsTile(
            title: "Reminder Frequency", 
            subtitle: _selectedFrequency,
            icon: Icons.notifications, 
            onTap: () {
              _showFrequencyDialog(context);
            }
          ), 
          _buildSettingsTile(
            title: "Language", 
            subtitle: _selectedLanguage, 
            icon: Icons.language, 
            onTap: () {
              _showLanguageDialog(context);
            }
          ),
          _buildSettingsTile(
            title: "App Theme", 
            subtitle: _selectedAppTheme, 
            icon: Icons.palette, 
            onTap: () {
              _showThemeDialog(context);
            }
          )
        ]
      )
    );
  }

  Widget _buildSettingsTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), 
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)), 
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), 
      onTap: onTap,
    );
  }

  void _showFrequencyDialog(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Reminder Frequency"),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              _dialogOption(context, "Daily", SettingType.reminderFrequency), 
              _dialogOption(context, "Weekly", SettingType.reminderFrequency),
              _dialogOption(context, "Monthly", SettingType.reminderFrequency),
            ],
          )
        );
      }
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog( 
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(context, "English", SettingType.language),
              _dialogOption(context, "Mandarin", SettingType.language),
            ]
          )
        );
      }
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(context, "Light", SettingType.appTheme),
              _dialogOption(context, "Dark", SettingType.appTheme),
              _dialogOption(context, "System Default", SettingType.appTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogOption(BuildContext context, String option, SettingType settingType) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState((){
          switch (settingType) {
            case SettingType.reminderFrequency:
              _selectedFrequency = option; 
              break; 
            case SettingType.language:
              _selectedLanguage = option; 
              break; 
            case SettingType.appTheme: 
              _selectedAppTheme = option; 
              break; 
          }
        Navigator.pop(context); // close the dialog when the option is selected
      }
    );
  }
    ); 
}
}
