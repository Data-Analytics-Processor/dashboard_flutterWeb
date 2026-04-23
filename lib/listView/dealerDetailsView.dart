// lib/listView/dealerDetailsView.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:adminapp/ReusableConstants/constants.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/outstandingReports_model.dart';
class DealerDetailsView extends StatelessWidget {
  final String dealerName;
  final List<CollectionReport> collections;
  final List<ProjectionReport> projections;
  final List<OutstandingReport> outstanding;

  const DealerDetailsView({
    super.key,
    required this.dealerName,
    this.collections = const [],
    this.projections = const [],
    this.outstanding = const [],
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final double totalCollected = collections.fold(0.0, (s, e) => s + e.amount);
    final double totalProjected = projections.fold(0.0, (s, e) => s + (e.collectionAmount ?? 0));
    final double totalOutstanding = outstanding.fold(0.0, (s, e) => s + e.pendingAmt);

    String zone = "N/A";
    String district = "N/A";
    String salesPromoter = "N/A";
    String institution = "N/A";
    DateTime? lastPaymentDate;

    if (collections.isNotEmpty) {
      collections.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));
      final latest = collections.first;

      zone = latest.zone ?? "N/A";
      district = latest.district ?? "N/A";
      salesPromoter = latest.salesPromoterName ?? "N/A";
      institution = latest.institution;
      lastPaymentDate = latest.voucherDate;

    } else if (projections.isNotEmpty) {
      final latest = projections.first;
      zone = latest.zone;
      institution = latest.institution;

    } else if (outstanding.isNotEmpty) {
      final latest = outstanding.first;
      zone = latest.zone ?? "N/A";
      institution = latest.isAccountJsbJud ? "JSB" : "JUD";
    }

    final currency = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN', decimalDigits: 1);
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          dealerName,
          style: const TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryAccent.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                institution,
                style: const TextStyle(
                  color: _primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- PROFILE CARD ---
            _buildProfileCard(zone, district, salesPromoter, lastPaymentDate, dateFormatter),

            const SizedBox(height: 24),

            // --- STATS ---
            Row(
              children: [
                Expanded(child: _buildStatCard("Collected", currency.format(totalCollected), Icons.download_done_rounded, _successGreen)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard("Projected", currency.format(totalProjected), Icons.trending_up_rounded, Colors.orangeAccent)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard("Outstanding", currency.format(totalOutstanding), Icons.warning_amber_rounded, Colors.redAccent)),
              ],
            ),

            const SizedBox(height: 32),

            // --- CHART ---
            if (collections.isNotEmpty) ...[
              const Text(
                "Payment History Trend",
                style: TextStyle(color: _textWhite, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: _buildSparkline(collections),
              ),
            ],

            const SizedBox(height: 32),

            // --- TRANSACTIONS ---
            const Text(
              "Recent Transactions",
              style: TextStyle(color: _textWhite, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildTransactionList(collections),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String zone, String district, String sp, DateTime? lastPay, DateFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,6))
        ],
      ),
      child: Column(
        children: [
          _buildRow(Icons.map_rounded, "Zone / District", "$zone / $district"),
          const Divider(color: _borderColor, height: 24),
          _buildRow(Icons.person_pin_circle_rounded, "Sales Promoter", sp),
          const Divider(color: _borderColor, height: 24),
          _buildRow(
            Icons.history_rounded,
            "Last Payment",
            lastPay != null ? fmt.format(lastPay) : "No History",
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: _textGrey, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _textGrey, fontSize: 11)),
            Text(
              value,
              style: TextStyle(
                color: _textWhite.withOpacity(isHighlight ? 1 : 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: _textGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: _textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSparkline(List<CollectionReport> data) {
    if (data.isEmpty) return const SizedBox();

    Map<int, double> grouped = {};
    for (var d in data) {
      int day = d.voucherDate.millisecondsSinceEpoch;
      grouped[day] = (grouped[day] ?? 0) + d.amount;
    }

    final sortedSpots = grouped.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (sortedSpots.length == 1) {
      sortedSpots.add(FlSpot(sortedSpots[0].x + 86400000, sortedSpots[0].y));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((s) {
                final date = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                return LineTooltipItem(
                  "${DateFormat('MMM dd').format(date)}\n${NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN').format(s.y)}",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: sortedSpots,
            isCurved: true,
            color: _primaryAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _primaryAccent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<CollectionReport> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length > 10 ? 10 : data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.voucherNo, style: const TextStyle(color: _textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(DateFormat('dd MMM yyyy').format(item.voucherDate), style: const TextStyle(color: _textGrey, fontSize: 11)),
                ],
              ),
              Text(
                NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0).format(item.amount),
                style: const TextStyle(color: _successGreen, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}