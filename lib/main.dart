// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import 'pages/AppSelector.dart';
import 'pages/LoginPage.dart';

void main() {
  runApp(const AnalyticsApp());
}

class AnalyticsApp extends StatelessWidget {
  const AnalyticsApp({super.key});

  // --- LIGHT THEME COLORS ---
  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Platform',
      debugShowCheckedModeBanner: false,
      
      // Clean, modern light theme
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: _bgWhite,
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: _textBlack,
          displayColor: _textBlack,
        ),
        colorScheme: const ColorScheme.light(
          primary: _primaryNavy,
          background: _bgWhite,
          surface: Colors.white,
          onSurface: _textBlack,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: _textBlack),
          titleTextStyle: TextStyle(color: _textBlack, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      
      // --- ROUTING LOGIC ---
      // We start at AppSelector, which handles Auto-Login and Role Routing
      initialRoute: '/', 
      routes: {
        '/': (context) => const AppSelector(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}