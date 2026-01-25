// lib/pages/SideNavBar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        color: kBlackBg,
        // Optional: Add a subtle border or shadow to separate it from the body
        border: Border(right: BorderSide(color: Color(0xFF222222))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LOGO ---
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                'Data Analytics',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 60),

          // --- NAVIGATION ---
          Text("MENU", style: GoogleFonts.spaceGrotesk(color: Colors.grey[800], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          
          _buildNavItem(0, "Dashboard", Icons.grid_view_rounded),
          _buildNavItem(1, "AI Analyst", Icons.chat_bubble_rounded),
          _buildNavItem(2, "Reports", Icons.folder_copy_rounded),

          const Spacer(),

          // --- USER PROFILE ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurfaceBlack,
              borderRadius: BorderRadius.circular(16), // Rounded profile card
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[900],
                  radius: 16,
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("User Name", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text("Pro Plan", style: TextStyle(color: kNeonGreen.withOpacity(0.8), fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    bool isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: BorderRadius.circular(50), // Fully rounded interaction
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? kNeonGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(50), // Pill Shape
            ),
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: isSelected ? Colors.black : kTextGrey, 
                  size: 18
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.black : kTextGrey, // Black text on Green button for contrast
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
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