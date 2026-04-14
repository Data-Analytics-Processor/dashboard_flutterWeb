// lib/pages/sales-marketing/subPages/salesData.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';

class SalesDataTab extends StatelessWidget {
  final List<SalesData> salesData;
  final String reportDate;

  const SalesDataTab({
    super.key,
    required this.salesData,
    required this.reportDate,
  });

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(
        child: Text("No Sales Data found for the latest report.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dealer & Zone Wise Sales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  DataColumn(label: Text("Dealer Name", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Area", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("District", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Total Sales", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Target", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Achieved %", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Asking Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: salesData.map((data) => DataRow(cells: [
                  DataCell(Text(data.dealerName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(data.area)),
                  DataCell(Text(data.district)),
                  DataCell(Text(data.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  DataCell(Text(data.target.toStringAsFixed(2))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: double.tryParse(data.achievedPercentage.replaceAll('%', '')) != null && double.parse(data.achievedPercentage.replaceAll('%', '')) >= 100 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data.achievedPercentage, 
                        style: TextStyle(
                          color: double.tryParse(data.achievedPercentage.replaceAll('%', '')) != null && double.parse(data.achievedPercentage.replaceAll('%', '')) >= 100 
                              ? Colors.green.shade700 
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    )
                  ),
                  DataCell(
                    Text(
                      (data.askingRate ?? data.avgRequiredPerDay ?? 0).toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}