// lib/pages/SavedAnalyticsPage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';

class SavedAnalyticsPage extends StatelessWidget {
  const SavedAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Saved Reports", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 40),
          
          Expanded(
            child: ListView(
              children: [
                _buildReportItem("Q3 Financial Breakdown", "PDF • 2.4 MB", "Today, 10:42 AM"),
                _buildReportItem("User Churn Analysis", "Excel • 840 KB", "Yesterday"),
                _buildReportItem("Server Load Metrics", "CSV • 12 MB", "Jan 20, 2026"),
                _buildReportItem("Marketing Campaign Results", "PDF • 4.1 MB", "Jan 18, 2026"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportItem(String name, String meta, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceBlack,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: kNeonGreen, size: 32),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(meta, style: const TextStyle(color: kTextGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: kTextGrey, fontSize: 14)),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}