// lib/pages/AppSelector.dart
import 'package:flutter/material.dart';
import '../models/users_model.dart';
import '../api/auth_service.dart';
import 'LoginPage.dart';
import 'MasterNavigatorScreen.dart';

// Department Home Pages
import 'finance/HomePage.dart';
import 'hr/HomePage.dart';
import 'logistics/HomePage.dart';
import 'sales-marketing/HomePage.dart';
import 'technical-sales/HomePage.dart';

// --- HELPER ROUTING METHOD ---
Widget getDepartmentHomePage(String role, User user) {
  final r = role.toLowerCase();
  if (r.contains('logistics')) return LogisticsHomePage(user: user, deptName: "Logistics");
  if (r.contains('finance')) return FinanceHomePage(user: user, deptName: "Finance");
  if (r.contains('human resources') || r.contains('hr')) return HRHomePage(user: user, deptName: "Human Resources");
  if (r.contains('sales-marketing')) return SalesHomePage(user: user, deptName: "Sales & Marketing");
  if (r.contains('technical-sales')) return TechnicalHomePage(user: user, deptName: "Technical Sales");
  
  // Fallback
  return UnderDevelopmentScreen(user: user); 
}

class AppSelector extends StatefulWidget {
  const AppSelector({super.key});

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  final AuthService _authService = AuthService();

  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _checkAutoLoginAndRoute();
  }

  Future<void> _checkAutoLoginAndRoute() async {
    try {
      final User? user = await _authService.tryAutoLogin();

      if (!mounted) return;

      if (user == null) {
        _navigateToLogin();
        return;
      }

      // ROUTING LOGIC
      final isAdmin =
        user.jobRoles.any((r) => r.toLowerCase().contains("admin")) ||
        (user.orgRole ?? "").toLowerCase().contains("admin");

      if (!isAdmin && user.jobRoles.length == 1) {
        // Single Role -> Straight to their dashboard
        Widget targetHomePage = getDepartmentHomePage(user.jobRoles.first, user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => targetHomePage),
        );
      } else {
        // Multiple Roles -> Go to Master Navigator
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MasterNavigatorScreen(user: user)),
        );
      }
      
    } catch (e) {
      if (mounted) _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _primaryNavy.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, size: 50, color: _primaryNavy),
            ),
            const SizedBox(height: 32),
            const Text(
              "Authenticating Session...",
              style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

class UnderDevelopmentScreen extends StatelessWidget {
  final User user;

  const UnderDevelopmentScreen({super.key, required this.user});

  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: _bgWhite,
        elevation: 0,
        title: const Text(
          "Coming Soon",
          style: TextStyle(color: _textBlack, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _textBlack),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_rounded,
                  size: 80, color: _primaryNavy.withOpacity(0.2)),

              const SizedBox(height: 24),

              const Text(
                "Sorry, this section is under development.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textBlack,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "We're working on bringing this feature to you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _textGrey,
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MasterNavigatorScreen(user: user),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Dashboard"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
