// lib/pages/HomePage.dart
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/services/stats_service.dart';
import 'package:dashboard_flutter/services/report_service.dart'; // Import ReportService to fix the list variable
import 'package:dashboard_flutter/ReusableConstants/constants.dart';

class HomePage extends StatelessWidget {
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  // Helper to format bytes to readable string
String _formatDataSize(int totalBytes) {
  if (totalBytes < 1024) return "${totalBytes} B";
  if (totalBytes < 1024 * 1024) return "${(totalBytes / 1024).toStringAsFixed(1)} KB";
  if (totalBytes < 1024 * 1024 * 1024) return "${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  return "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
}

  @override
  Widget build(BuildContext context) {
    final stats = StatsService();
    final reports = ReportService();
    final isMobile = Responsive.isMobile(context);
    final double padding = isMobile ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: kBankBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NOVA Dashboard",
                      style: TextStyle(color: kTextWhite, fontSize: isMobile ? 26 : 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your data at a glance",
                      style: TextStyle(color: kTextGrey, fontSize: 15),
                    ),
                  ],
                ),
                if (isMobile) const SizedBox(height: 20),
                // "New Analysis" Button
                ElevatedButton.icon(
                  onPressed: () => onNavigate(1), 
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  label: const Text("New Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBankPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: kBankPrimary.withOpacity(0.4),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),

            // --- CARDS SECTION (Adaptive) ---
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  // 1. QUERY CARD
                  ValueListenableBuilder<int>(
                    valueListenable: stats.queryCount,
                    builder: (ctx, count, _) {
                      return _BankCard(
                        title: "Total Queries",
                        value: "$count",
                        subtitle: "AI assisted querries",
                        icon: Icons.api_rounded,
                        isPrimary: true,
                      );
                    },
                  ),
                  // 2. REPORTS CARD
                  ValueListenableBuilder<List<Report>>(
                    valueListenable: reports.reportsNotifier,
                    builder: (ctx, reportList, _) {
                      return _BankCard(
                        title: "Reports Generated",
                        value: "${reportList.length}",
                        subtitle: "Exported files",
                        icon: Icons.description_rounded,
                        isPrimary: false,
                      );
                    },
                  ),
                  // 3. STATIC CARD
                  ValueListenableBuilder<List<Report>>(
                    valueListenable: reports.reportsNotifier,
                    builder: (context, reportList, _) {
                      final int totalBytes = reportList.fold(
                        0, 
                        (sum, report) => sum + (report.content?.length ?? 0)
                      );
                      final String usedData = _formatDataSize(totalBytes);
                      return _BankCard(
                        title: "Data Processed",
                        value: "$usedData / 5 GB",
                        subtitle: "Cloud usage",
                        icon: Icons.cloud_done_outlined,
                        isPrimary: false,
                      );
                    },
                  ),
                ];

                if (isMobile) {
                  return Column(
                    children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
                  );
                } else {
                  return Row(
                    children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: c))).toList(),
                  );
                }
              },
            ),

            const SizedBox(height: 50),

            // --- QUICK ACTIONS ---
            Text("Quick Actions", style: TextStyle(color: kTextWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ActionTile(
                  icon: Icons.chat_bubble_outline_rounded, 
                  label: "AI Advisor", 
                  subLabel: "Get insights",
                  isMobile: isMobile,
                  onTap: () => onNavigate(1)
                ),
                _ActionTile(
                  icon: Icons.receipt_long_rounded, 
                  label: "View Reports", 
                  subLabel: "Download CSVs",
                  isMobile: isMobile,
                  onTap: () => onNavigate(2)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;

  const _BankCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isPrimary ? kBankPrimary : kBankSurface,
        borderRadius: BorderRadius.circular(24),
        border: isPrimary ? null : Border.all(color: kBorderColor),
        gradient: isPrimary ? const LinearGradient(
          colors: [kBankPrimary, kBankAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        boxShadow: isPrimary ? [
           BoxShadow(color: kBankPrimary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary ? Colors.white.withOpacity(0.2) : kBankSurfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isPrimary ? Colors.white : kTextWhite, size: 22),
              ),
              if (isPrimary)
                const Icon(Icons.blur_on, color: Colors.white24, size: 30),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(
                color: isPrimary ? Colors.white : kTextWhite,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(title.toUpperCase(), style: TextStyle(
                    color: isPrimary ? Colors.white70 : kTextGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
                  const Spacer(),
                  Text(subtitle, style: TextStyle(
                    color: isPrimary ? Colors.white60 : kTextGrey.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  final bool isMobile;

  const _ActionTile({
    required this.icon, 
    required this.label, 
    required this.subLabel, 
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    double width = isMobile 
        ? (MediaQuery.of(context).size.width / 2) - 32 
        : 160;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      hoverColor: kBankSurfaceLight,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kBankSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kBankPrimary, size: 32),
            const SizedBox(height: 20),
            Text(label, style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subLabel, style: const TextStyle(color: kTextGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}