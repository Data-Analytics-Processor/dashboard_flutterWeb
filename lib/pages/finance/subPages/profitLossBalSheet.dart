// lib/pages/finance/subPages/profitLossBalSheet.dart
import 'package:flutter/material.dart';
import '../../../../models/finance_reports_model.dart';
import '../../../components/data_table_reusable.dart';

class ProfitLossBalSheetTab extends StatelessWidget {
  final List<FinanceRow> data;
  final List<String> months;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const ProfitLossBalSheetTab({
    super.key,
    required this.data,
    required this.months,
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
      return Container(
        color: _bgDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text("Failed to load data\n$errorMessage", textAlign: TextAlign.center, style: const TextStyle(color: _textGrey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry, 
                style: ElevatedButton.styleFrom(backgroundColor: _primaryAccent), 
                child: const Text("Retry", style: TextStyle(color: Colors.white))
              )
            ],
          ),
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text("No P&L / Balance Sheet data found.", style: TextStyle(color: _textGrey, fontSize: 16))
      );
    }

    return Container(
      color: _bgDark,
      child: RefreshIndicator(
        onRefresh: () async => onRetry(),
        color: _primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: ReusableDataTable<FinanceRow>(
            title: "PL & BS Status",
            subtitle: "As of: $reportDate",
            columns: ["Particular", ...months, "Remarks"],
            data: data,
            buildCells: (row) => [
              DataCell(Text(row.particular, style: const TextStyle(fontWeight: FontWeight.w600))),
              ...months.map((m) => DataCell(Text(row.statuses[m]?.toString() ?? '-'))),
              DataCell(Text(row.remarks ?? '-', style: const TextStyle(color: _textGrey))),
            ],
          ),
        ),
      ),
    );
  }
}