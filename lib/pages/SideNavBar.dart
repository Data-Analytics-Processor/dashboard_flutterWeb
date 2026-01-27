import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';

class SideNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const SideNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
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
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NOVA", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2)),
                  Text("ANALYTICS", style: TextStyle(color: kTextGrey, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ],
              )
            ],
          ),
          const SizedBox(height: 50),

          // --- NAVIGATION ---
          Text("MENU", style: TextStyle(color: kTextGrey.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          _NavTile(
            label: "Overview",
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavTile(
            label: "AI Advisor",
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            isActive: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _NavTile(
            label: "Statements",
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
            isActive: selectedIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          
          const Spacer(),
          
          // --- USER PROFILE ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBankSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kBankSurfaceLight,
                  child: const Icon(Icons.person, size: 18, color: kTextWhite),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("User Name", style: TextStyle(color: kTextWhite, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("Pro Plan", style: TextStyle(color: kTextGrey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
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
              color: isActive ? kBankPrimary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: kBankPrimary.withOpacity(0.3)) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? kBankPrimary : kTextGrey,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? kBankPrimary : kTextGrey,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
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