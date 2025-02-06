import 'package:finalprojectsuphakorn/home_page.dart';
import 'package:finalprojectsuphakorn/howto.dart';
import 'package:finalprojectsuphakorn/share.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Example',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(239, 245, 188, 2)),
        useMaterial3: true,
      ),
      home: menupage(),
    );
  }
}

class menupage extends StatefulWidget {
  @override
  State<menupage> createState() => _MenuPageState();
}

class _MenuPageState extends State<menupage> {
  int _selectedIndex = 0; // Track selected tab

  // List of widgets to display for each tab
  final List<Widget> _pages = [
    HomePage(), // First tab (Home)
    howtopage(), // Second tab (Profile)
    sharepage(), // Third tab (Settings)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[
          _selectedIndex], // Display the corresponding page based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
