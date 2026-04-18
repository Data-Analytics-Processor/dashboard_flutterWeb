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

  Map<String, Map<String, List<CollectionData>>> _groupCollectionData(List<CollectionData> data) {
    Map<String, Map<String, List<CollectionData>>> grouped = {};
    for (var item in data) {
      String zone = (item.zone.isNotEmpty && item.zone != '-') ? item.zone : 'Unknown Zone';
      String dist = (item.district.isNotEmpty && item.district != '-') ? item.district : 'Unknown District';

      if (!grouped.containsKey(zone)) {
        grouped[zone] = {};
      }
      if (!grouped[zone]!.containsKey(dist)) {
        grouped[zone]![dist] = [];
      }
      grouped[zone]![dist]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (collectionData.isEmpty) {
      return const Center(
        child: Text("No Collection Data found for the latest report.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final totalCollections = collectionData.fold<double>(0, (sum, item) => sum + item.amount);
    final groupedData = _groupCollectionData(collectionData);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Daily Collection Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Total Collected: ${currencyFormatter.format(totalCollections)}", style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0A2540).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text("As of: $reportDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CollectionZoneView(groupedData: groupedData),
        ],
      ),
    );
  }
}