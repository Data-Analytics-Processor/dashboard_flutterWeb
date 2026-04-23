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

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Platform',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bgDark,

        // --- TYPOGRAPHY ---
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: _textWhite,
          displayColor: _textWhite,
        ),

        // --- COLOR SYSTEM ---
        colorScheme: const ColorScheme.dark(
          primary: _primaryAccent,
          background: _bgDark,
          surface: _surfaceDark,
          onSurface: _textWhite,
        ),

        // --- APP BAR ---
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgDark,
          elevation: 0,
          iconTheme: IconThemeData(color: _textWhite),
          titleTextStyle: TextStyle(
            color: _textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // --- DIVIDERS ---
        dividerColor: Color(0xFF333333),

        // --- INPUTS (GLOBAL CONSISTENCY) ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceDark,
          labelStyle: const TextStyle(color: _textGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _primaryAccent, width: 1.5),
          ),
        ),

        // --- BUTTONS ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      // --- ROUTING ---
      initialRoute: '/',
      routes: {
        '/': (context) => const AppSelector(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}