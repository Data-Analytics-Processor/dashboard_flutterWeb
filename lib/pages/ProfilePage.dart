// lib/pages/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/users_model.dart';
import '../api/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBankSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Log Out", style: TextStyle(color: kTextWhite)),
        content: const Text(
          "Are you sure you want to log out of the Admin Portal?",
          style: TextStyle(color: kTextGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: kTextGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Log Out", style: TextStyle(color: kExpenseRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MY PROFILE",
          style: TextStyle(
            color: kTextWhite,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: kTextGrey),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // --- 1. PROFILE HEADER ---
            _buildHeader(),
            
            const SizedBox(height: 32),

            // --- 2. PERSONAL DETAILS ---
            _buildSectionHeader("Personal Information"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: kBankSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.email_outlined, "Email", user.email),
                  _buildDivider(),
                  _buildInfoRow(Icons.phone_outlined, "Phone", user.phoneNumber ?? "N/A"),
                  _buildDivider(),
                  _buildInfoRow(Icons.location_on_outlined, "Region", "${user.region ?? '-'} / ${user.area ?? '-'}"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 3. ACCOUNT STATUS ---
            _buildSectionHeader("Account Status"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: kBankSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: Column(
                children: [
                   _buildInfoRow(Icons.badge_outlined, "Admin ID", user.adminAppLoginId ?? "N/A"),
                   _buildDivider(),
                   _buildInfoRow(Icons.verified_user_outlined, "Role", user.role.toUpperCase()),
                   _buildDivider(),
                   _buildStatusRow(user.status),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 4. LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kExpenseRed.withOpacity(0.1),
                  foregroundColor: kExpenseRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: kExpenseRed.withOpacity(0.3)),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "A";
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBankSurface, width: 4),
            boxShadow: [
              BoxShadow(
                color: kBankPrimary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: kBankPrimary,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kTextWhite,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kBankPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBankPrimary.withOpacity(0.3)),
          ),
          child: Text(
            user.role.replaceAll('-', ' ').toUpperCase(),
            style: const TextStyle(
              color: kBankPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: kTextGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: kTextGrey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: kTextGrey.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: kTextWhite, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.lightGreen : kExpenseRed;
    final icon = isActive ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: kTextGrey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status",
                  style: TextStyle(color: kTextGrey.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: kBorderColor.withOpacity(0.5));
  }
}