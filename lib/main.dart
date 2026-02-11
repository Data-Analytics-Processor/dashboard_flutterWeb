import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'models/users_model.dart'; 
import 'pages/NavBar.dart'; 
import 'pages/HomePage.dart';
import 'pages/InsightsPage.dart';
import 'pages/SavedAnalyticsPage.dart';
import 'pages/LoginPage.dart';
import 'pages/ProfilePage.dart';

void main() {
  runApp(const AnalyticsApp());
}

class AnalyticsApp extends StatelessWidget {
  const AnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JUD-JSB Admin Dashboard',
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
      // --- ROUTING LOGIC ---
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(), 
      },
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
  int _insightsInitialTab = 0;
  User? _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the User object passed from LoginScreen arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _currentUser = args;
    }
  }

  void switchTab(int index, {int initialTab = 0}) {
    setState(() {
      _selectedIndex = index;
      _insightsInitialTab = initialTab;
    });
  }

  List<Widget> get _pages => [
    HomePage(onNavigate: switchTab), 
    InsightsPage(initialTabIndex: _insightsInitialTab), 
    const SavedAnalyticsPage(),
    ProfilePage(user: _currentUser!),
  ];

  @override
  Widget build(BuildContext context) {
    // <--- CHANGED: Safety check for null user
    if (_currentUser == null) {
      // If no user data (e.g. hot restart), go back to login or show loader
      // For dev purposes, a loader prevents the crash:
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                  BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Insights'),
                  BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Reports'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
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
                  user: _currentUser!, // <--- CHANGED: Pass the non-null user to NavBar
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