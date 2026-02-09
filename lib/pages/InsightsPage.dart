// lib/pages/InsightsPage.dart
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  // ---------------------------------------------------------------------------
  // 1. DATA SIMULATION
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _rawData = List.generate(50, (index) {
    final random = Random();
    final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
    final amount = (random.nextDouble() * 500) + 20;
    final categories = ['SaaS', 'Infrastructure', 'Marketing', 'Office', 'Travel'];
    return {
      'id': 'TRX-${1000 + index}',
      'date': date,
      'amount': amount,
      'category': categories[random.nextInt(categories.length)],
      'merchant': 'Vendor ${String.fromCharCode(65 + random.nextInt(26))}',
    };
  })..sort((a, b) => b['date'].compareTo(a['date']));

  // Filter State
  String _selectedTimeRange = 'Last 30 Days';
  final List<String> _timeRanges = ['Last 7 Days', 'Last 30 Days', 'All Time'];

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // 2. AGGREGATION LOGIC
    // -------------------------------------------------------------------------
    final totalSpend = _rawData.fold(0.0, (sum, item) => sum + (item['amount'] as double));
    final avgSpend = _rawData.isEmpty ? 0.0 : totalSpend / _rawData.length;

    // Group by Category
    final Map<String, double> categorySpend = {};
    for (var row in _rawData) {
      final cat = row['category'] as String;
      final amt = row['amount'] as double;
      categorySpend[cat] = (categorySpend[cat] ?? 0) + amt;
    }

    // Group by Date
    final Map<int, double> dailySpend = {};
    for (var row in _rawData) {
      final date = row['date'] as DateTime;
      final dayKey = date.day;
      dailySpend[dayKey] = (dailySpend[dayKey] ?? 0) + (row['amount'] as double);
    }

    // -------------------------------------------------------------------------
    // 3. RESPONSIVE UI BUILD
    // -------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: kBankBg,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint: If width is less than 900, treat as mobile/tablet
          final isMobile = constraints.maxWidth < 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                _buildHeader(isMobile),
                const SizedBox(height: 24),

                // --- KPI CARDS (Responsive) ---
                _buildKPISection(
                  isMobile: isMobile,
                  totalSpend: totalSpend,
                  count: _rawData.length,
                  avgSpend: avgSpend,
                ),
                const SizedBox(height: 24),

                // --- CHARTS ROW (Responsive) ---
                _buildChartsSection(
                  isMobile: isMobile,
                  dailySpend: dailySpend,
                  categorySpend: categorySpend,
                ),
                const SizedBox(height: 24),

                // --- DRILL DOWN TABLE ---
                _buildRecentTransactionsTable(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildKPISection({
    required bool isMobile,
    required double totalSpend,
    required int count,
    required double avgSpend,
  }) {
    final cards = [
      _KPICard(
        title: "Total Spend",
        value: NumberFormat.simpleCurrency().format(totalSpend),
        icon: Icons.attach_money,
        color: kBankPrimary,
      ),
      _KPICard(
        title: "Transactions",
        value: count.toString(),
        icon: Icons.receipt_long,
        color: Colors.orangeAccent,
      ),
      _KPICard(
        title: "Avg. Ticket",
        value: NumberFormat.simpleCurrency(decimalDigits: 0).format(avgSpend),
        icon: Icons.analytics,
        color: Colors.tealAccent,
      ),
    ];

    if (isMobile) {
      // Mobile: Column of cards
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: c,
                ))
            .toList(),
      );
    } else {
      // Desktop: Row of cards
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
          const SizedBox(width: 16),
          Expanded(child: cards[2]),
        ],
      );
    }
  }

  Widget _buildChartsSection({
    required bool isMobile,
    required Map<int, double> dailySpend,
    required Map<String, double> categorySpend,
  }) {
    final trendChart = _ChartContainer(
      title: "Spend Trend",
      child: _SpendLineChart(dailyData: dailySpend),
    );

    final catChart = _ChartContainer(
      title: "Top Categories",
      child: _CategoryBreakdown(data: categorySpend),
    );

    if (isMobile) {
      // Mobile: Stacked Charts
      return Column(
        children: [
          trendChart,
          const SizedBox(height: 24),
          catChart,
        ],
      );
    } else {
      // Desktop: Side by Side (2:1 Ratio)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: trendChart),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: catChart),
        ],
      );
    }
  }

  Widget _buildHeader(bool isMobile) {
    // If mobile, stack the text and the button. If desktop, separate them.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dashboard", style: TextStyle(color: kTextWhite, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Real-time financial overview", style: TextStyle(color: kTextGrey, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Export CSV"),
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextGrey,
                side: const BorderSide(color: kBorderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Dashboard", style: TextStyle(color: kTextWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Real-time overview of your financial data", style: TextStyle(color: kTextGrey, fontSize: 14)),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: const Text("Export CSV"),
            style: OutlinedButton.styleFrom(
              foregroundColor: kTextGrey,
              side: const BorderSide(color: kBorderColor),
            ),
          )
        ],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SHARED UI COMPONENTS (AppBar, Table, Cards)
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBankBg,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBankPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insights, color: kBankPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text("Financial Insights", style: TextStyle(color: kTextWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kBankSurfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorderColor),
          ),
          child: DropdownButton<String>(
            value: _selectedTimeRange,
            dropdownColor: kBankSurface,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: kTextGrey),
            style: const TextStyle(color: kTextWhite, fontSize: 13),
            items: _timeRanges.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedTimeRange = v!),
          ),
        )
      ],
    );
  }

  Widget _buildRecentTransactionsTable() {
    return Container(
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: const Text("Recent Transactions", style: TextStyle(color: kTextWhite, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1, color: kBorderColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rawData.take(8).length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = _rawData[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: kBankSurfaceLight,
                  child: Icon(Icons.business, color: kTextGrey, size: 18),
                ),
                title: Text(item['merchant'], style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.w500)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(item['date']), style: const TextStyle(color: kTextGrey, fontSize: 12)),
                trailing: Text(
                  NumberFormat.simpleCurrency().format(item['amount']),
                  style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS
// -----------------------------------------------------------------------------
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures full width in column mode
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: kTextGrey, fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: kTextWhite, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SpendLineChart extends StatelessWidget {
  final Map<int, double> dailyData;
  const _SpendLineChart({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final spots = dailyData.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) => Text(
                "${val.toInt()}",
                style: const TextStyle(color: kTextGrey, fontSize: 10),
              ),
              interval: 5,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: kBankPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: kBankPrimary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> data;
  const _CategoryBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final item = sorted[index];
        final pct = item.value / maxVal;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.key, style: const TextStyle(color: kTextWhite, fontSize: 13)),
                  Text(NumberFormat.compactCurrency(symbol: '\$').format(item.value),
                      style: const TextStyle(color: kTextGrey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(height: 6, decoration: BoxDecoration(color: kBankSurfaceLight, borderRadius: BorderRadius.circular(3))),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}