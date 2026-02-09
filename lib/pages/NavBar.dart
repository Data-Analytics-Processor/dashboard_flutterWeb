// lib/pages/NavBar.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/users_model.dart';
import 'ProfilePage.dart'; 

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBankBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BRAND LOGO ---
          Row(
            children: [
              Container(
                height: 42, width: 42,
                decoration: BoxDecoration(
                  color: kBankPrimary,
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [kBankPrimary, kBankAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: kBankPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                  ]
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("NOVA", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2)),
                  Text("INTELLIGENCE", style: TextStyle(color: kTextGrey, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ],
              )
            ],
          ),
          const SizedBox(height: 50),

          // --- NAVIGATION ---
          Text("PLATFORM", style: TextStyle(color: kTextGrey.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
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
          // 2. Wrapped in InkWell to make the whole card clickable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // 3. Navigate to Profile Page on click
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => ProfilePage(user: user))
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBankSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kBankPrimary,
                      child: Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "A",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user.firstName} ${user.lastName}", 
                            style: const TextStyle(color: kTextWhite, fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.role.toUpperCase(), 
                            style: const TextStyle(color: kTextGrey, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 4. Changed icon to 'Settings/Arrow' to indicate navigation
                    const Icon(Icons.arrow_forward_ios_rounded, color: kTextGrey, size: 14),
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
          hoverColor: kBankSurfaceLight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? kBankPrimary.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: kBankPrimary.withOpacity(0.3)) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? kBankPrimary : kTextGrey,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? kTextWhite : kTextGrey,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: kBankPrimary,
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