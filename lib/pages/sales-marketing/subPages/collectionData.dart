// lib/pages/sales-marketing/subPages/collectionData.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';
import 'package:intl/intl.dart';

class CollectionDataTab extends StatelessWidget {
  final List<CollectionData> collectionData;
  final String reportDate;

  const CollectionDataTab({
    super.key,
    required this.collectionData,
    required this.reportDate,
  });

  @override
  Widget build(BuildContext context) {
    if (collectionData.isEmpty) {
      return const Center(
        child: Text("No Collection Data found for the latest report.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final totalCollections = collectionData.fold<double>(0, (sum, item) => sum + item.amount);

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
                  Text("Total Collected: ${currencyFormatter.format(totalCollections)}", style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text("Voucher No", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Party Name", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Zone", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Sales Promoter", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: collectionData.map((data) => DataRow(cells: [
                  DataCell(Text(data.voucherNo, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                  DataCell(Text(data.partyName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(data.zone)),
                  DataCell(Text(data.salesPromoter)),
                  DataCell(Text(currencyFormatter.format(data.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}