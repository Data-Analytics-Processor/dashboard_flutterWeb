// lib/pages/NavBar.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import './ProfilePage.dart'; // Adjust import path based on your folder structure
class SideNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final User user;

  const SideNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.user,
  });

  // --- DARK THEME COLORS ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BRAND LOGO ---
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _primaryAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Admin",
                    style: TextStyle(
                        color: _textWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 1.0),
                  ),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                        color: _textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 50),

          // --- NAVIGATION ---
          const Text(
            "PLATFORM",
            style: TextStyle(
                color: _textGrey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),

          _NavTile(
            label: "Mission Control",
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavTile(
            label: "Insights Studio",
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights_rounded,
            isActive: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _NavTile(
            label: "AI Analyst",
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome,
            isActive: selectedIndex == 2,
            onTap: () => onTabSelected(2),
          ),

          const Spacer(),

          // --- USER PROFILE ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(user: user)),
                );
              },
              borderRadius: BorderRadius.circular(14),
              hoverColor: _surfaceDark,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _primaryAccent.withOpacity(0.2),
                      child: Text(
                        user.email.isNotEmpty
                            ? user.email[0].toUpperCase()
                            : "A",
                        style: const TextStyle(
                            color: _primaryAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email.split('@')[0],
                            style: const TextStyle(
                                color: _textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.orgRole?.toUpperCase() ?? "ADMIN",
                            style: const TextStyle(
                                color: _textGrey,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: _textGrey, size: 14),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: SideNavBar._surfaceDark,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? SideNavBar._primaryAccent.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? SideNavBar._primaryAccent
                      : SideNavBar._textGrey,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? SideNavBar._primaryAccent
                        : SideNavBar._textGrey,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: SideNavBar._primaryAccent,
                      shape: BoxShape.circle,
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}