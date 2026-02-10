// lib/pages/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/users_model.dart';
import '../api/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _handleRefresh() async {
    // Re-fetch user data using the existing auto-login logic which fetches the profile
    final freshUser = await AuthService().tryAutoLogin();
    
    if (mounted && freshUser != null) {
      setState(() {
        _currentUser = freshUser;
      });
    }
  }

  Future<void> _handleLogout() async {
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
      if (mounted) {
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: kBankPrimary,
        backgroundColor: kBankSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Allows refresh even if content is short
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
                    _buildInfoRow(Icons.email_outlined, "Email", _currentUser.email),
                    _buildDivider(),
                    _buildInfoRow(Icons.phone_outlined, "Phone", _currentUser.phoneNumber ?? "N/A"),
                    _buildDivider(),
                    _buildInfoRow(Icons.location_on_outlined, "Region", "${_currentUser.region ?? '-'} / ${_currentUser.area ?? '-'}"),
                  ],
                ),
              ),
    
              const SizedBox(height: 32),
    
              // --- 3. LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogout,
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
              // Extra padding for scroll
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _currentUser.firstName.isNotEmpty ? _currentUser.firstName[0].toUpperCase() : "A";
    
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
          "${_currentUser.firstName} ${_currentUser.lastName}",
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
            _currentUser.role.replaceAll('-', ' ').toUpperCase(),
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

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: kBorderColor.withOpacity(0.5));
  }
}