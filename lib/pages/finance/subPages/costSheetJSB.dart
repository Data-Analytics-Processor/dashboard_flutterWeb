// lib/pages/finance/subPages/costSheetJSB.dart
import 'package:flutter/material.dart';
import '../../../../models/finance_reports_model.dart';

class CostSheetJSBTab extends StatelessWidget {
  final List<FinanceRow> data;
  final List<String> months;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const CostSheetJSBTab({
    super.key,
    required this.data,
    required this.months,
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
              ElevatedButton(onPressed: onRetry, style: ElevatedButton.styleFrom(backgroundColor: _primaryAccent), child: const Text("Retry", style: TextStyle(color: Colors.white)))
            ],
          ),
        ),
      );
    }

    if (data.isEmpty) return const Center(child: Text("No JSB Cost Sheet data found.", style: TextStyle(color: _textGrey, fontSize: 16)));

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("JSB Cost Sheet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textWhite)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _primaryAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text("As of: $reportDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: _surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith((states) => _bgDark),
                      headingTextStyle: const TextStyle(color: _textGrey, fontWeight: FontWeight.w600),
                      dataTextStyle: const TextStyle(color: _textWhite),
                      columns: [
                        const DataColumn(label: Text("Particular")),
                        ...months.map((m) => DataColumn(label: Text(m))),
                        const DataColumn(label: Text("Remarks")),
                      ],
                      rows: data.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row.particular, style: const TextStyle(fontWeight: FontWeight.w600))),
                          ...months.map((m) => DataCell(Text(row.statuses[m]?.toString() ?? '-'))),
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