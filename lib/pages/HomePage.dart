// lib/pages/HomePage.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart'; // Added Import

class HomePage extends StatefulWidget {
  final Function(int, {int initialTab})
  onNavigate; // Updated callback signature

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;

  List<CollectionReport> _collections = [];
  List<ProjectionReport> _projections = []; // Store projections

  // Aggregated Stats
  double _totalCollection = 0;
  double _totalOrderProjection = 0;
  double _totalCollectionProjection = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch both Collections and Projections
      final colData = await _api.fetchCollectionReports(limit: 50);
      final projData = await _api.fetchProjectionReports(limit: 50);

      if (mounted) {
        setState(() {
          _collections = colData;
          _projections = projData;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load data";
          _isLoading = false;
        });
      }
    }
  }

  void _calculateStats() {
    _totalCollection = _collections.fold(0.0, (sum, item) {
      final v = item.amount;
      return sum + (v.isFinite ? v : 0.0);
    });

    _totalOrderProjection = _projections.fold(0.0, (sum, item) {
      final v = item.orderQtyMt ?? 0.0;
      return sum + (v.isFinite ? v : 0.0);
    });

    _totalCollectionProjection = _projections.fold(0.0, (sum, item) {
      final v = item.collectionAmount ?? 0.0;
      return sum + (v.isFinite ? v : 0.0);
    });
  }

  String safeCurrency(NumberFormat fmt, double value) {
    if (!value.isFinite) return "₹0";
    return fmt.format(value);
  }

  String safeIntLabel(double value) {
    if (!value.isFinite) return "0";
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final currencyCompact = NumberFormat.compactCurrency(
      symbol: '₹',
      decimalDigits: 1,
      locale: 'en_IN',
    );
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kBankPrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: kExpenseRed)),
      );
    }

    return Scaffold(
      backgroundColor: kBankBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Mission Control",
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Financial Overview",
                      style: TextStyle(
                        color: kTextWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: kBankSurfaceLight,
                  radius: 24,
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: kTextWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. MAIN KPI: COLLECTIONS ---
            InkWell(
              onTap: () =>
                  widget.onNavigate(1, initialTab: 0), // Tab 0 = Collections
              borderRadius: BorderRadius.circular(24),
              child: _buildBigCard(
                title: "TOTAL COLLECTIONS",
                value: safeCurrency(currencyCompact, _totalCollection),
                subtitle: "Realized Revenue (Last 50)",
                color1: kBankPrimary,
                color2: kBankPrimary.withOpacity(0.8),
                chart: _buildSparkline(
                  _collections.map((e) => e.amount).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. SECONDARY KPI: PROJECTIONS ---
            InkWell(
              onTap: () =>
                  widget.onNavigate(1, initialTab: 1), // Tab 1 = Projections
              borderRadius: BorderRadius.circular(24),
              child: _buildBigCard(
                title: "TOTAL PROJECTIONS",
                value: safeCurrency(
                  currencyCompact,
                  _totalCollectionProjection,
                ),
                subtitle: "Projected Collections (Last 50)",
                color1: Colors.deepPurple,
                color2: Colors.purpleAccent.withOpacity(0.8),
                chart: _buildSparkline(
                  _projections.map((e) => e.collectionAmount ?? 0).toList(),
                ),
                extraValue: "${safeIntLabel(_totalOrderProjection)} MT Orders",
              ),
            ),

            // Removed "Quick Actions" and "Transactions/Avg Ticket" as requested
          ],
        ),
      ),
    );
  }

  Widget _buildBigCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color1,
    required Color color2,
    required Widget chart,
    String? extraValue,
  }) {
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (extraValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    extraValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 50, child: chart),
        ],
      ),
    );
  }

  Widget _buildSparkline(List<double> values) {
    if (values.isEmpty) return const SizedBox();

    final safeValues = values.map((v) => v.isFinite ? v : 0.0).toList();

    final recent = safeValues.take(10).toList().reversed.toList();

    final minY = recent.reduce((a, b) => a < b ? a : b);
    final maxY = recent.reduce((a, b) => a > b ? a : b);

    if (minY == maxY) return const SizedBox(); // 🚑 critical fix

    final spots = recent
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: minY - (minY * 0.1),
        maxY: maxY + (maxY * 0.1),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
