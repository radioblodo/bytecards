import 'package:flutter/material.dart';

import 'theme_manager.dart';
import 'locale_manager.dart';
import 'l10n/generated/app_localizations.dart';
import 'pages/home_page.dart';
import 'pages/statistics_page.dart';
import 'pages/settings_page.dart';

class ByteCardsApp extends StatefulWidget {
  const ByteCardsApp({Key? key}) : super(key: key);

  @override
  _ByteCardsAppState createState() => _ByteCardsAppState();
}

class _ByteCardsAppState extends State<ByteCardsApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, currentLocale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: currentTheme,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              locale: currentLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: _MainScaffold(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            );
          },
        );
      },
    );
  }
}

class _MainScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const _MainScaffold({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  static final List<Widget> _pages = [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Add null check fallback just in case localization fails
    final homeTitle = loc?.home ?? 'Home';
    final statsTitle = loc?.statistics ?? 'Statistics';
    final settingsTitle = loc?.settings ?? 'Settings';

    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: statsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: settingsTitle,
          ),
        ],
      ),
    );
  }
}
