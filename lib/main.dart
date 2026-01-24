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
  // This state controls the active page
  int _selectedIndex = 0;

  // The List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
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
            flex: 2, // 20% Width
            child: SideNavBar(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),

          // --- RIGHT PANEL (4/5 WIDTH) ---
          Expanded(
            flex: 8, // 80% Width
            child: Container(
              color: Colors.black, // Pure black background for content
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