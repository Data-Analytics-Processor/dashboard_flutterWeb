// lib/pages/sales-marketing/subPages/collectionData.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';
import 'package:intl/intl.dart';
import '../views/drillDownView.dart';
class CollectionDataTab extends StatelessWidget {
  final List<CollectionData> collectionData;
  final String reportDate;

  const CollectionDataTab({
    super.key,
    required this.collectionData,
    required this.reportDate,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  Map<String, Map<String, List<CollectionData>>> _groupCollectionData(
      List<CollectionData> data) {
    Map<String, Map<String, List<CollectionData>>> grouped = {};
    for (var item in data) {
      String zone =
          (item.zone.isNotEmpty && item.zone != '-') ? item.zone : 'Unknown Zone';
      String dist = (item.district.isNotEmpty && item.district != '-')
          ? item.district
          : 'Unknown District';

      grouped.putIfAbsent(zone, () => {});
      grouped[zone]!.putIfAbsent(dist, () => []);
      grouped[zone]![dist]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (collectionData.isEmpty) {
      return const Center(
        child: Text(
          "No Collection Data found for the latest report.",
          style: TextStyle(color: _textGrey, fontSize: 16),
        ),
      );
    }

    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final totalCollections =
        collectionData.fold<double>(0, (sum, item) => sum + item.amount);
    final groupedData = _groupCollectionData(collectionData);

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Collection Report",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Collected: ${currencyFormatter.format(totalCollections)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // --- DATE BADGE ---
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "As of: $reportDate",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primaryAccent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- DATA VIEW ---
            Container(
              decoration: BoxDecoration(
                color: _surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: CollectionZoneView(
                groupedData: groupedData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}