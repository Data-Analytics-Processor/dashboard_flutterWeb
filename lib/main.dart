// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/api/auth_service.dart';
import 'pages/SideNavBar.dart'; 
import 'pages/HomePage.dart';
import 'pages/ChatPage.dart';
import 'pages/SavedAnalyticsPage.dart';
import 'pages/LoginPage.dart'; 

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
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: kBankPrimary,
          surface: kBankSurface,
          background: kBankBg,
          onSurface: kTextWhite,
        ),
        cardTheme: CardThemeData(
          color: kBankSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBorderColor, width: 1),
          ),
        ),
        iconTheme: const IconThemeData(color: kTextGrey),
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
      // Use the AuthWrapper to decide the initial route
      home: const AuthWrapper(),
    );
  }
}

// --- NEW: AuthWrapper to handle initial routing ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        // Show a blank screen with background color while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kBankBg,
            body: Center(child: CircularProgressIndicator(color: kBankPrimary)),
          );
        }
        
        // If a token exists, go straight to MainLayout
        if (snapshot.hasData && snapshot.data != null) {
          return const MainLayout();
        }
        
        // Otherwise, show the Login Page
        return const LoginPage();
      },
    );
  }
}

// --- MainLayout remains exactly as you had it ---
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

  List<Widget> get _pages => [
    HomePage(onNavigate: switchTab), 
    const ChatPage(),
    const SavedAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
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
            if (!isMobile)
              SizedBox(
                width: 260,
                child: SideNavBar(
                  selectedIndex: _selectedIndex,
                  onTabSelected: switchTab, 
                ),
              ),
            
            if (!isMobile)
              Container(width: 1, color: kBorderColor),
  
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