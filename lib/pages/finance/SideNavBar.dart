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

  // --- LIGHT THEME COLORS ---
  static const Color _bgWhite = Color(0xFFFFFFFF); // Pure White Sidebar
  static const Color _surfaceHover = Color(0xFFF1F5F9); // Light Slate for hover
  static const Color _primaryNavy = Color(0xFF0A2540); // Deep Navy
  static const Color _textBlack = Color(0xFF1E293B); // Slate Black
  static const Color _textGrey = Color(0xFF64748B); // Cool Grey
  static const Color _borderColor = Color(0xFFE2E8F0); // Light Grey Border

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgWhite,
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
                  color: _primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryNavy.withOpacity(0.2), 
                      blurRadius: 12, 
                      offset: const Offset(0, 4)
                    )
                  ]
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Admin", 
                    style: TextStyle(color: _textBlack, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.0)
                  ),
                  Text(
                    "Dashboard", 
                    style: TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 50),

          // --- NAVIGATION ---
          const Text(
            "PLATFORM", 
            style: TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)
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
          
          // --- USER PROFILE (Clickable) ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => ProfilePage(user: user))
                );
              },
              borderRadius: BorderRadius.circular(14),
              hoverColor: _surfaceHover,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: _textBlack.withOpacity(0.02), 
                      blurRadius: 10, 
                      offset: const Offset(0, 4)
                    )
                  ]
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _primaryNavy.withOpacity(0.1),
                      child: Text(
                        user.email.isNotEmpty ? user.email[0].toUpperCase() : "A",
                        style: const TextStyle(color: _primaryNavy, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email.split('@')[0], // Shows name part of email
                            style: const TextStyle(color: _textBlack, fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.orgRole?.toUpperCase() ?? "ADMIN", 
                            style: const TextStyle(color: _textGrey, fontSize: 10, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: _textGrey, size: 14),
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
          hoverColor: SideNavBar._surfaceHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // Active gets a soft navy highlight, inactive is transparent
              color: isActive ? SideNavBar._primaryNavy.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? SideNavBar._primaryNavy : SideNavBar._textGrey,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? SideNavBar._primaryNavy : SideNavBar._textGrey,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: SideNavBar._primaryNavy,
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