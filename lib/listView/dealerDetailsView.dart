// lib/listView/dealerDetailsView.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';

class DealerDetailsView extends StatelessWidget {
  final String dealerName;
  final List<CollectionReport> collections;
  final List<ProjectionReport> projections;

  const DealerDetailsView({
    super.key,
    required this.dealerName,
    this.collections = const [],
    this.projections = const [],
  });

  @override
  Widget build(BuildContext context) {
    // --- 1. Aggregation Logic ---
    final double totalCollected = collections.fold(0.0, (s, e) => s + e.amount);
    final double totalProjected = projections.fold(0.0, (s, e) => s + (e.collectionAmount ?? 0));
    
    // Extract Metadata from the first available record (Dealer details shouldn't change per record)
    String zone = "N/A";
    String district = "N/A";
    String salesPromoter = "N/A";
    String institution = "N/A"; // JSB/JUD/etc.
    DateTime? lastPaymentDate;

    if (collections.isNotEmpty) {
      // Sort to find latest date
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
    }

    final currency = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN', decimalDigits: 1);
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(dealerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kBankPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBankPrimary.withOpacity(0.5))
            ),
            child: Center(
              child: Text(
                institution, 
                style: const TextStyle(color: kBankPrimary, fontWeight: FontWeight.bold, fontSize: 12),
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
            // --- 2. Profile Card ---
            _buildProfileCard(zone, district, salesPromoter, lastPaymentDate, dateFormatter),
            
            const SizedBox(height: 24),

            // --- 3. Financial Overview (Grid) ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard("Total Collections", currency.format(totalCollected), Icons.download_done_rounded, kSuccessGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard("Projected", currency.format(totalProjected), Icons.trending_up_rounded, Colors.orangeAccent),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- 4. Trend Chart ---
            if (collections.isNotEmpty) ...[
              const Text("Payment History Trend", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBankSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderColor),
                ),
                child: _buildSparkline(collections),
              ),
            ],

            const SizedBox(height: 32),

            // --- 5. Recent Transactions List ---
            const Text("Recent Transactions", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 16)),
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
        color: kBankSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))
        ]
      ),
      child: Column(
        children: [
          _buildRow(Icons.map_rounded, "Zone / District", "$zone / $district"),
          const Divider(color: kBorderColor, height: 24),
          _buildRow(Icons.person_pin_circle_rounded, "Sales Promoter", sp),
          const Divider(color: kBorderColor, height: 24),
          _buildRow(
            Icons.history_rounded, 
            "Last Payment", 
            lastPay != null ? fmt.format(lastPay) : "No History",
            isHighlight: true
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: kTextGrey, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kTextGrey, fontSize: 11)),
            Text(value, style: TextStyle(
              color: isHighlight ? kTextWhite : kTextWhite.withOpacity(0.9), 
              fontWeight: FontWeight.w600,
              fontSize: 14
            )),
          ],
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: kTextGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: kTextWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSparkline(List<CollectionReport> data) {
    if (data.isEmpty) return const SizedBox();
    
    // Group by Date for cleaner chart
    Map<int, double> grouped = {};
    for (var d in data) {
      // Use epoch day to group
      int day = d.voucherDate.millisecondsSinceEpoch;
      grouped[day] = (grouped[day] ?? 0) + d.amount;
    }

    final sortedSpots = grouped.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
        ..sort((a,b) => a.x.compareTo(b.x));

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
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                );
              }).toList();
            }
          )
        ),
        lineBarsData: [
          LineChartBarData(
            spots: sortedSpots,
            isCurved: true,
            color: kBankPrimary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: kBankPrimary.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<CollectionReport> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length > 10 ? 10 : data.length, // Show max 10 recent
      separatorBuilder: (_,__) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kBankSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor.withOpacity(0.5))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.voucherNo, style: const TextStyle(color: kTextWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(DateFormat('dd MMM yyyy').format(item.voucherDate), style: const TextStyle(color: kTextGrey, fontSize: 11)),
                ],
              ),
              Text(
                NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0).format(item.amount),
                style: const TextStyle(color: kSuccessGreen, fontWeight: FontWeight.bold, fontSize: 14),
              )
            ],
          ),
        );
      },
    );
  }
}