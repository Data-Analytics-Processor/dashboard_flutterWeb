// lib/pages/logistics/subPages/rawMaterialStockData.dart
import 'package:flutter/material.dart';
import '../../../../models/logistics_reports_model.dart';

class RawMaterialStockDataTab extends StatelessWidget {
  final List<RawMaterialStockRow> data;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const RawMaterialStockDataTab({
    super.key,
    required this.data,
    required this.reportDate,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
  });

  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: _primaryAccent));
    if (errorMessage != null) return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)));
    if (data.isEmpty) return const Center(child: Text("No Raw Material Stock Data found.", style: TextStyle(color: _textGrey)));

    return Container(
      color: _bgDark,
      child: RefreshIndicator(
        onRefresh: () async => onRetry(),
        color: _primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Raw Material Stock - $reportDate", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith((states) => _bgDark),
                      headingTextStyle: const TextStyle(color: _textGrey, fontWeight: FontWeight.w600),
                      dataTextStyle: const TextStyle(color: _textWhite),
                      columns: const [
                        DataColumn(label: Text("Material")),
                        DataColumn(label: Text("Unit")),
                        DataColumn(label: Text("JSB Closing Stock")),
                        DataColumn(label: Text("JUD Closing Stock")),
                        DataColumn(label: Text("Total Stock")),
                        DataColumn(label: Text("Remarks")),
                      ],
                      rows: data.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(row.unit)),
                          DataCell(Text(row.jsbClosingStock?.toStringAsFixed(2) ?? '-')),
                          DataCell(Text(row.judClosingStock?.toStringAsFixed(2) ?? '-')),
                          DataCell(Text(row.totalStock?.toStringAsFixed(2) ?? '-', style: const TextStyle(color: Colors.greenAccent))),
                          DataCell(Text(row.remarks ?? '-', style: const TextStyle(color: _textGrey))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}