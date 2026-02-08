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
      title: 'Nova Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBankBg,
        // Manrope is the standard "Fintech" font. If not available, use Inter.
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: kBankPrimary,
          surface: kBankSurface,
          background: kBankBg,
          onSurface: kTextWhite,
        ),
        // --- FIX: Use CardThemeData instead of CardTheme ---
        cardTheme: CardThemeData(
          color: kBankSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBorderColor, width: 1),
          ),
        ),
        iconTheme: const IconThemeData(color: kTextGrey),
        // Bottom Nav Theme for Mobile
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kBankSurface,
          selectedItemColor: kBankPrimary,
          unselectedItemColor: kTextGrey,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
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
  int _selectedIndex = 0;

  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Pass navigation callback to HomePage
  List<Widget> get _pages => [
    HomePage(onNavigate: switchTab), 
    const InsightsPage(),
    const SavedAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      // --- MOBILE BOTTOM NAV ---
      bottomNavigationBar: isMobile 
          ? Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kBorderColor)),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: switchTab,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'AI'),
                  BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Reports'),
                ],
              ),
            )
          : null,
      
      body: SafeArea(
        child: Row(
          children: [
            // --- DESKTOP SIDEBAR ---
            if (!isMobile)
              SizedBox(
                width: 260,
                child: SideNavBar(
                  selectedIndex: _selectedIndex,
                  onTabSelected: switchTab, 
                ),
              ),
            
            // --- VERTICAL DIVIDER (Desktop Only) ---
            if (!isMobile)
              Container(width: 1, color: kBorderColor),
  
            // --- MAIN CONTENT AREA ---
            Expanded(
              child: Container(
                color: kBankBg,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}