import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/statistics_page.dart';
import 'pages/settings_page.dart';

class ByteCardsApp extends StatefulWidget{
  const ByteCardsApp({Key? key}) : super(key: key);

  @override
  _ByteCardsAppState createState() => _ByteCardsAppState(); 
}

class _ByteCardsAppState extends State<ByteCardsApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: ThemeData.dark(), // add light/dark mode switch later
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}