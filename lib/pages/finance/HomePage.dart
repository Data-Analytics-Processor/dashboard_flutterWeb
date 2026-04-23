// lib/pages/finance/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import 'ProfilePage.dart';

class FinanceHomePage extends StatelessWidget {
  final User user;
  final String deptName;

  const FinanceHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  // --- NEW DARK THEME COLORS ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: _textWhite,
        ), // Ensures back button is white
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deptName,
              style: const TextStyle(
                color: _textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Welcome back, ${user.email.split('@')[0]}",
              style: const TextStyle(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: _primaryAccent,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: user),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_customize_rounded,
                size: 80,
                color: _primaryAccent.withOpacity(
                  0.3,
                ), // Adjusted opacity for dark mode
              ),
              const SizedBox(height: 24),
              Text(
                "Welcome to $deptName",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _textWhite,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "This workspace is currently under construction. Specific widgets and data views for this department will be populated here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textGrey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
