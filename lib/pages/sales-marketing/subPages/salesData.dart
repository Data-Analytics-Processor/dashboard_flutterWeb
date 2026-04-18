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

  Map<String, Map<String, List<SalesData>>> _groupSalesData(List<SalesData> data) {
    Map<String, Map<String, List<SalesData>>> grouped = {};
    for (var item in data) {
      String dist = item.district.isNotEmpty ? item.district : 'Unknown District';
      String area = item.area.isNotEmpty ? item.area : 'Unknown Area';

      if (!grouped.containsKey(dist)) {
        grouped[dist] = {};
      }
      if (!grouped[dist]!.containsKey(area)) {
        grouped[dist]![area] = [];
      }
      grouped[dist]![area]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(
        child: Text("No Sales Data found for the latest report.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    final groupedData = _groupSalesData(salesData);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dealer & District Wise Sales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0A2540).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text("As of: $reportDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SalesZoneView(groupedData: groupedData),
        ],
      ),
    );
  }
}