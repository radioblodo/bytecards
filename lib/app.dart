// import 'package:flutter/material.dart';

// import 'theme_manager.dart';
// import 'locale_manager.dart';
// import 'l10n/generated/app_localizations.dart';
// import 'pages/home_page.dart';
// import 'pages/statistics_page.dart';
// import 'pages/settings_page.dart';

// class ByteCardsApp extends StatefulWidget {
//   const ByteCardsApp({Key? key}) : super(key: key);

//   @override
//   _ByteCardsAppState createState() => _ByteCardsAppState();
// }

// class _ByteCardsAppState extends State<ByteCardsApp> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) => setState(() => _selectedIndex = index);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeNotifier,
//       builder: (context, currentTheme, _) {
//         return ValueListenableBuilder<Locale>(
//           valueListenable: localeNotifier,
//           builder: (context, currentLocale, _) {
//             return MaterialApp(
//               debugShowCheckedModeBanner: false,
//               themeMode: currentTheme,
//               theme: ThemeData.light(),
//               darkTheme: ThemeData.dark(),
//               locale: currentLocale,
//               supportedLocales: AppLocalizations.supportedLocales,
//               localizationsDelegates: AppLocalizations.localizationsDelegates,
//               home: _MainScaffold(
//                 selectedIndex: _selectedIndex,
//                 onItemTapped: _onItemTapped,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// /// Custom clipper to carve a notch under the selected item.
// class _NavBarClipper extends CustomClipper<Path> {
//   final int selectedIndex;
//   final int itemCount;
//   final double notchRadius;
//   final double notchDepth;

//   _NavBarClipper(
//     this.selectedIndex,
//     this.itemCount,
//     this.notchRadius,
//     this.notchDepth,
//   );

//   @override
//   Path getClip(Size size) {
//     final w = size.width;
//     final h = size.height;
//     final seg = w / itemCount;
//     final cx = selectedIndex * seg + seg / 2;
//     final r = notchRadius;
//     final d = notchDepth;

//     final p = Path();
//     p.moveTo(0, 0);
//     p.lineTo(cx - r - d, 0);
//     p.quadraticBezierTo(cx - r, 0, cx - r + d, d);
//     p.arcToPoint(
//       Offset(cx + r - d, d),
//       radius: Radius.circular(r),
//       clockwise: false,
//     );
//     p.quadraticBezierTo(cx + r, 0, cx + r + d, 0);
//     p.lineTo(w, 0);
//     p.lineTo(w, h);
//     p.lineTo(0, h);
//     p.close();
//     return p;
//   }

//   @override
//   bool shouldReclip(covariant _NavBarClipper old) =>
//       old.selectedIndex != selectedIndex;
// }

// class _MainScaffold extends StatelessWidget {
//   final int selectedIndex;
//   final ValueChanged<int> onItemTapped;

//   const _MainScaffold({
//     Key? key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   }) : super(key: key);

//   static final _pages = [HomePage(), StatisticsPage(), SettingsPage()];

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);
//     final titles = [
//       loc?.home ?? 'Home',
//       loc?.statistics ?? 'Statistics',
//       loc?.settings ?? 'Settings',
//     ];

//     const double barHeight = 64;
//     const double ballSize = 56;
//     const double notchDepth = 16;
//     final items = _pages.length;
//     final w = MediaQuery.of(context).size.width;
//     final itemW = w / items;

//     // Dynamic background: white in light, dark grey in dark
//     final theme = Theme.of(context);
//     final bgColor =
//         theme.brightness == Brightness.light ? Colors.white : Colors.grey[850]!;
//     final accent = const Color(0xFF4A45C4);

//     return Scaffold(
//       body: _pages[selectedIndex],
//       bottomNavigationBar: SizedBox(
//         height: barHeight + ballSize / 2,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Nav bar background with notch
//             ClipPath(
//               clipper: _NavBarClipper(
//                 selectedIndex,
//                 items,
//                 ballSize / 2,
//                 notchDepth,
//               ),
//               child: Container(
//                 height: barHeight + ballSize / 2,
//                 color: bgColor,
//                 child: Padding(
//                   padding: EdgeInsets.only(top: ballSize / 2),
//                   child: Theme(
//                     data: theme.copyWith(
//                       splashFactory: NoSplash.splashFactory,
//                       highlightColor: Colors.transparent,
//                     ),
//                     child: BottomNavigationBar(
//                       type: BottomNavigationBarType.fixed,
//                       backgroundColor: Colors.transparent,
//                       elevation: 0,
//                       currentIndex: selectedIndex,
//                       onTap: onItemTapped,
//                       selectedItemColor: accent,
//                       unselectedItemColor: theme.disabledColor,
//                       showSelectedLabels: true,
//                       showUnselectedLabels: true,
//                       enableFeedback: false,
//                       items: List.generate(
//                         items,
//                         (i) => BottomNavigationBarItem(
//                           icon: Icon(
//                             [Icons.home, Icons.bar_chart, Icons.settings][i],
//                           ),
//                           activeIcon: SizedBox.shrink(),
//                           label: titles[i],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Floating ball
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 100),
//               curve: Curves.easeOut,
//               bottom: barHeight - ballSize / 2 + (notchDepth / 2),
//               left: selectedIndex * itemW + (itemW - ballSize) / 2,
//               child: Container(
//                 width: ballSize,
//                 height: ballSize,
//                 decoration: BoxDecoration(
//                   color: accent,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   [Icons.home, Icons.bar_chart, Icons.settings][selectedIndex],
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

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
  final ValueChanged<int> onItemTapped;

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
    AppLocalizations.of(context);
    final icons = [Icons.home, Icons.bar_chart, Icons.settings];

    final theme = Theme.of(context);
    final bgColor =
        theme.brightness == Brightness.light
            ? const Color.fromARGB(245, 225, 225, 225)
            : Colors.grey[850]!;
    final accentColor = const Color(0xFF4A45C4);
    return Scaffold(
      // Extend body behind navigation for transparent background
      extendBody: true,
      body: _pages[selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // completely disable ink splash & highlight
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: CurvedNavigationBar(
          index: selectedIndex,
          height: 60,
          items:
              icons
                  .map((icon) => Icon(icon, size: 30, color: Colors.white))
                  .toList(),
          color: bgColor,
          buttonBackgroundColor: accentColor,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0),
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 285),
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
