// lib/pages/MasterNavigatorScreen.dart
import 'package:flutter/material.dart';
import '../models/users_model.dart';
import 'AppSelector.dart'; // To access the getDepartmentHomePage helper

class MasterNavigatorScreen extends StatelessWidget {
  final User user;

  const MasterNavigatorScreen({super.key, required this.user});

  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  static const List<String> _allDepartments = [
    "Finance",
    "Human Resources",
    "Logistics",
    "Sales-Marketing",
    "Technical-Sales",
  ];

  bool get isAdmin {
    final roles = user.jobRoles.map((e) => e.toLowerCase()).toList();

    final jobRoleAdmin = roles.any((r) => r.contains("admin"));
    final orgRoleAdmin = (user.orgRole ?? "").toLowerCase().contains("admin");

    return jobRoleAdmin || orgRoleAdmin;
  }

  List<String> get rolesToShow {
    return isAdmin ? _allDepartments : user.jobRoles;
  }

  // Helper to get nice icons for departments
  IconData _getIconForRole(String role) {
    final r = role.toLowerCase();
    if (r.contains('logistics')) return Icons.local_shipping_outlined;
    if (r.contains('finance')) return Icons.account_balance_wallet_outlined;
    if (r.contains('accounts')) return Icons.receipt_long_outlined;
    if (r.contains('hr') || r.contains('human')) return Icons.groups_outlined;
    if (r.contains('sales')) return Icons.trending_up_rounded;
    if (r.contains('technical')) return Icons.engineering_outlined;
    return Icons.business_rounded;
  }

  // Helper to format the display name
  String _formatRoleName(String role) {
    return role.replaceAll('-', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: _bgWhite,
        elevation: 0,
        // Removed Profile action button entirely
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              children: [
                const Icon(Icons.hub_rounded, size: 54, color: _primaryNavy),
                const SizedBox(height: 24),
                const Text(
                  "Master Control",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select a department portal to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Map over the user's job roles and build a card for each
                ...rolesToShow
                    .map(
                      (role) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to the specific department
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      getDepartmentHomePage(role, user),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: _textBlack.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _primaryNavy.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getIconForRole(role),
                                      color: _primaryNavy,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatRoleName(role),
                                          style: const TextStyle(
                                            color: _textBlack,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Access Dashboard",
                                          style: TextStyle(
                                            color: _textGrey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: _textGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
