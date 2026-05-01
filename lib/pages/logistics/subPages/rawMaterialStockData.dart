// lib/pages/logistics/subPages/rawMaterialStockData.dart
import 'package:flutter/material.dart';
import '../../../../models/logistics_reports_model.dart';
import '../../../components/data_table_reusable.dart';

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
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryAccent));
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)));
    }

    if (data.isEmpty) {
      return const Center(child: Text("No Raw Material Stock Data found.", style: TextStyle(color: _textGrey)));
    }

    return Container(
      color: _bgDark,
      child: RefreshIndicator(
        onRefresh: () async => onRetry(),
        color: _primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: ReusableDataTable<RawMaterialStockRow>(
            title: "Raw Material Stock",
            subtitle: "As of: $reportDate",
            columns: const [
              "Material",
              "Unit",
              "JSB Closing Stock",
              "JUD Closing Stock",
              "Total Stock",
              "Remarks"
            ],
            data: data,
            buildCells: (row) => [
              DataCell(Text(row.material, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(row.unit)),
              DataCell(Text(row.jsbClosingStock?.toStringAsFixed(2) ?? '-')),
              DataCell(Text(row.judClosingStock?.toStringAsFixed(2) ?? '-')),
              DataCell(Text(row.totalStock?.toStringAsFixed(2) ?? '-', style: const TextStyle(color: Colors.greenAccent))),
              DataCell(Text(row.remarks ?? '-', style: const TextStyle(color: _textGrey))),
            ],
          ),
        ),
      ),
    );
  }
}