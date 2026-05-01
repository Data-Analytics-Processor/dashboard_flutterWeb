// lib/pages/sales-marketing/subPages/collectionData.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sales_reports_model.dart';
import '../../../components/data_table_reusable.dart';

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
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _successGreen = Color(0xFF22C55E);

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

    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final totalCollections = collectionData.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ReusableDataTable<CollectionData>(
          title: "Daily Collection Report",
          subtitle: "Total Collected: ${currencyFormatter.format(totalCollections)} | As of: $reportDate",
          columns: const [
            "Voucher No",
            "Date",
            "Party Name",
            "Zone",
            "District",
            "Promoter",
            "Amount"
          ],
          data: collectionData,
          buildCells: (item) {
            return [
              DataCell(Text(item.voucherNo)),
              DataCell(Text(item.date)),
              DataCell(Text(
                item.partyName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(item.zone)),
              DataCell(Text(item.district)),
              DataCell(Text(item.salesPromoter)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currencyFormatter.format(item.amount),
                    style: const TextStyle(
                      color: _successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}