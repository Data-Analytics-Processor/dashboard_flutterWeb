// lib/pages/logistics/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import 'ProfilePage.dart'; 

class LogisticsHomePage extends StatelessWidget {
  final User user;
  final String deptName;

  const LogisticsHomePage({
    super.key, 
    required this.user, 
    required this.deptName
  });

  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deptName,
              style: const TextStyle(color: _textBlack, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Welcome back, ${user.email.split('@')[0]}",
              style: const TextStyle(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: _primaryNavy, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
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
              Icon(Icons.dashboard_customize_rounded, size: 80, color: _primaryNavy.withOpacity(0.2)),
              const SizedBox(height: 24),
              Text(
                "Welcome to $deptName",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _textBlack),
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