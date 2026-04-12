// lib/pages/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/users_model.dart';
import '../../api/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  // --- LIGHT THEME COLORS ---
  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _errorRed = Color(0xFFEF4444);

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Sign Out",
            style: TextStyle(color: _textBlack, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to sign out?",
            style: TextStyle(color: _textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Sign Out"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<void> _launchDeleteAccountUrl(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLScZi6YujtVrzg4VRUvpQWTRhFAGkbuJJgc07BW56EA-njT7Fw/viewform?usp=publish-editor',
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the form. Please contact support.'),
            backgroundColor: _errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: _bgWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: _textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: _textBlack),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600), // Web constraint
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- AVATAR & HEADER ---
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: _primaryNavy.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryNavy.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.orgRole?.toUpperCase() ?? "ADMINISTRATOR",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryNavy,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // --- DETAILS CARD ---
                const Text(
                  "ACCOUNT DETAILS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _textGrey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                  child: Column(
                    children: [
                      _ProfileRow(
                        icon: Icons.badge_outlined,
                        label: "Admin ID",
                        value: user.id,
                      ),
                      const Divider(height: 1, color: _borderColor),
                      _ProfileRow(
                        icon: Icons.email_outlined,
                        label: "Email Address",
                        value: user.email,
                      ),
                      const Divider(height: 1, color: _borderColor),
                      _ProfileRow(
                        icon: Icons.work_outline_rounded,
                        label: "Department",
                        value: user.jobRoles.isNotEmpty
                            ? user.jobRoles
                                  .map(
                                    (role) =>
                                        role.replaceAll('-', ' ').toUpperCase(),
                                  )
                                  .join(', ')
                            : "General",
                      ),
                      const Divider(height: 1, color: _borderColor),
                      _ProfileRow(
                        icon: Icons.security_rounded,
                        label: "Permissions",
                        value: "${user.permissions.length} active roles",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- ACCOUNT SETTINGS / PRIVACY ---
                const Text(
                  "SECURITY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _textGrey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryNavy.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: _primaryNavy,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Privacy & Security',
                        style: TextStyle(
                          color: _textBlack,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 12),
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: const Icon(
                            Icons.delete_outline,
                            color: _errorRed,
                          ),
                          title: const Text(
                            "Request Account Deletion",
                            style: TextStyle(
                              color: _errorRed,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: _textGrey,
                          ),
                          onTap: () => _launchDeleteAccountUrl(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- LOGOUT BUTTON ---
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: _errorRed,
                      size: 20,
                    ),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: _errorRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _errorRed,
                      side: const BorderSide(color: _errorRed, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HELPER WIDGET FOR ROWS ---
class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: ProfilePage._textGrey),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ProfilePage._textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                color: ProfilePage._textBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
