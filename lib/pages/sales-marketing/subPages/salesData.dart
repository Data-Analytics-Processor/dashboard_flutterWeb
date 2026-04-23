// lib/pages/sales-marketing/subPages/salesData.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';
import '../views/drillDownView.dart';

class SalesDataTab extends StatelessWidget {
  final List<SalesData> salesData;
  final String reportDate;

  const SalesDataTab({
    super.key,
    required this.salesData,
    required this.reportDate,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  Map<String, Map<String, List<SalesData>>> _groupSalesData(
    List<SalesData> data,
  ) {
    Map<String, Map<String, List<SalesData>>> grouped = {};
    for (var item in data) {
      String dist = item.district.isNotEmpty
          ? item.district
          : 'Unknown District';
      String area = item.area.isNotEmpty ? item.area : 'Unknown Area';

      grouped.putIfAbsent(dist, () => {});
      grouped[dist]!.putIfAbsent(area, () => []);
      grouped[dist]![area]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(
        child: Text(
          "No Sales Data found for the latest report.",
          style: TextStyle(color: _textGrey, fontSize: 16),
        ),
      );
    }

    final groupedData = _groupSalesData(salesData);

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
                const Text(
                  "Dealer & District Wise Sales",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textWhite,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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

            // --- DATA CONTAINER ---
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
                  ),
                ],
              ),
              child: SalesZoneView(groupedData: groupedData),
            ),
          ],
        ),
      ),
    );
  }
}
