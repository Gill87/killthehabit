import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/pages/navigation_pages/home_page.dart';
import 'package:rehabit/pages/navigation_pages/notifications_page.dart';
import 'package:rehabit/pages/navigation_pages/progress_page.dart';
import 'package:rehabit/pages/navigation_pages/settings_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {

  int _selectedIndex = 0;

  // Your different pages (replace with your actual widgets)
  final List<Widget> _pages = [
    const HomePage(),      // Your dashboard content widget
    const ProgressPage(),       // Your progress content widget
    const NotificationsPage(),  // Your notifications content widget
    const SettingsPage(),       // Your settings content widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kill the Habit', style: GoogleFonts.ubuntu(fontSize: 28)),
        centerTitle: true,
      ),

      // Display Page
      body: _pages[_selectedIndex],  // Display content based on selected tab

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}