// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'pages/SideNavBar.dart'; 
import 'pages/HomePage.dart';
import 'pages/ChatPage.dart';
import 'pages/SavedAnalyticsPage.dart';

void main() {
  runApp(const AnalyticsApp());
}

class AnalyticsApp extends StatelessWidget {
  const AnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: kNeonGreen,
          surface: kSurfaceBlack,
          background: Colors.black,
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // State: Active Tab Index
  int _selectedIndex = 0;

  // Method to switch tabs (passed to children)
  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Getter for Pages (allows us to pass 'switchTab' to HomePage)
  List<Widget> get _pages => [
    HomePage(onNavigate: switchTab), 
    const ChatPage(),
    const SavedAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- LEFT PANEL (1/5 WIDTH) ---
          Expanded(
            flex: 2, 
            child: SideNavBar(
              selectedIndex: _selectedIndex,
              onTabSelected: switchTab, 
            ),
          ),

          // --- RIGHT PANEL (4/5 WIDTH) ---
          Expanded(
            flex: 8, 
            child: Container(
              color: Colors.black,
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}