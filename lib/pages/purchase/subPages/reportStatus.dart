// lib/pages/purchase/subPages/reportStatus.dart
import 'package:flutter/material.dart';
import '../../../../models/purchase_reports_model.dart';
import '../../../components/data_table_reusable.dart';

class ReportStatusTab extends StatelessWidget {
  final List<PurchaseReportStatusRow> data;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const ReportStatusTab({
    super.key,
    required this.data,
    required this.reportDate,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
  });

  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
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
                child: const Text("Retry", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text("No Report Status data found.", style: TextStyle(color: _textGrey, fontSize: 16)),
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
          child: ReusableDataTable<PurchaseReportStatusRow>(
            title: "Report Submissions Status",
            subtitle: "As of: $reportDate",
            columns: const ["Report Name", "Status"],
            data: data,
            buildCells: (row) {
              Color statusColor = _textWhite;
              if (row.status.toLowerCase().contains('received') || row.status.toLowerCase() == 'yes' || row.status.toLowerCase() == 'done') {
                statusColor = Colors.greenAccent;
              } else if (row.status.toLowerCase().contains('pending') || row.status.toLowerCase() == 'no') {
                statusColor = Colors.orangeAccent;
              } else if (row.status.toLowerCase().contains('delayed') || row.status.toLowerCase().contains('error')) {
                statusColor = Colors.redAccent;
              }

              return [
                DataCell(Text(row.reportName, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(row.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
              ];
            },
          ),
        ),
      ),
    );
  }
}