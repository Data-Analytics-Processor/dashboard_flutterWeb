// lib/pages/logistics/subPages/transporterPaymentData.dart
import 'package:flutter/material.dart';
import '../../../../models/logistics_reports_model.dart';
import '../../../components/data_table_reusable.dart';

class TransporterPaymentDataTab extends StatelessWidget {
  final List<TransporterPaymentRow> data;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const TransporterPaymentDataTab({
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
      return const Center(child: Text("No Transporter Payment Data found.", style: TextStyle(color: _textGrey)));
    }

    return Container(
      color: _bgDark,
      child: RefreshIndicator(
        onRefresh: () async => onRetry(),
        color: _primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: ReusableDataTable<TransporterPaymentRow>(
            title: "Transporter Payments",
            subtitle: "As of: $reportDate",
            columns: const [
              "S.No",
              "Transporter Name",
              "Payment Amount",
              "Remarks"
            ],
            data: data,
            buildCells: (row) => [
              DataCell(Text(row.serialNo?.toString() ?? '-')),
              DataCell(Text(row.transporterName, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(row.paymentAmount != null ? "₹${row.paymentAmount?.toStringAsFixed(2)}" : '-')),
              DataCell(Text(row.remarks ?? '-', style: const TextStyle(color: _textGrey))),
            ],
          ),
        ),
      ),
    );
  }
}