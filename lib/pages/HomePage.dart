// lib/pages/HomePage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import 'package:dashboard_flutter/services/report_service.dart';
import 'package:dashboard_flutter/services/stats_service.dart';

class HomePage extends StatelessWidget {
  // Callback to switch tabs in MainLayout
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = StatsService();
    final reports = ReportService();

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          const Text("Welcome back, User", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Here is what's happening with your data today.", style: TextStyle(color: kTextGrey)),
          const SizedBox(height: 40),

          // --- ROW 1: NAVIGATION ACTION CARDS (Half Width) ---
          SizedBox(
            height: 140, // Fixed height for action cards
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    "Start Analysis", 
                    "Chat with AI", 
                    Icons.auto_awesome_rounded, // Swapped for a rounded icon variant
                    () => onNavigate(1), // Navigate to Chat Tab (Index 1)
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildActionCard(
                    "View Library", 
                    "Saved Reports", 
                    Icons.folder_open_rounded, 
                    () => onNavigate(2), // Navigate to Reports Tab (Index 2)
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- ROW 2: LIVE STATS (Real-Time Data) ---
          Expanded(
            child: Row(
              children: [
                // 1. ACTIVE SESSIONS / QUERIES
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: stats.queryCount,
                    builder: (context, count, _) {
                      return _buildLiveStatCard(
                        "Total AI Queries", 
                        count.toString(), 
                        Icons.insights_rounded,
                        Colors.blueAccent,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                
                // 2. CREATED REPORTS
                Expanded(
                  child: ValueListenableBuilder<List<Report>>(
                    valueListenable: reports.reportsNotifier,
                    builder: (context, reportList, _) {
                      return _buildLiveStatCard(
                        "Reports Generated", 
                        reportList.length.toString(), 
                        Icons.description_rounded,
                        kNeonGreen,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Smaller, clickable navigation card
  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: kSurfaceBlack,
      // SMOOTH ROUNDED CORNERS (24px)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), 
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: kNeonGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24), // Matches the shape
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  // FULLY ROUNDED ICON BACKGROUND
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white10),
                ),
                child: Icon(icon, color: kNeonGreen, size: 24),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: kTextGrey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Large stat card for displaying numbers
  Widget _buildLiveStatCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurfaceBlack,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(24), // SMOOTH ROUNDED CORNERS
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle, // CIRCLE BACKGROUND
            ),
            child: Icon(icon, color: accentColor, size: 32),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value, 
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -2)
              ),
              Text(title, style: const TextStyle(color: kTextGrey, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}