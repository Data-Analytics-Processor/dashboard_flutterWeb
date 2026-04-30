// lib/pages/logistics/subPages/transporterPaymentData.dart
import 'package:flutter/material.dart';
import '../../../../models/logistics_reports_model.dart';

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
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: _primaryAccent));
    if (errorMessage != null) return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)));
    if (data.isEmpty) return const Center(child: Text("No Transporter Payment Data found.", style: TextStyle(color: _textGrey)));

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
              Text("Transporter Payments - $reportDate", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite)),
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
                        DataColumn(label: Text("S.No")),
                        DataColumn(label: Text("Transporter Name")),
                        DataColumn(label: Text("Payment Amount")),
                        DataColumn(label: Text("Remarks")),
                      ],
                      rows: data.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row.serialNo?.toString() ?? '-')),
                          DataCell(Text(row.transporterName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(row.paymentAmount != null ? "₹${row.paymentAmount?.toStringAsFixed(2)}" : '-')),
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
