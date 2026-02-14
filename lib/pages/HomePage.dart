// lib/pages/HomePage.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/outstandingReports_model.dart';
import '../models/projectionVsActualReports_model.dart';

class HomePage extends StatefulWidget {
  final Function(int, {int initialTab}) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;

  List<CollectionReport> _collections = [];
  List<ProjectionReport> _projections = [];
  List<OutstandingReport> _outstandings = [];
  List<ProjectionVsActualReport> _comparisons = [];

  // Aggregated Stats
  double _totalCollection = 0;
  double _totalOrderProjection = 0;
  double _totalOutstanding = 0;
  double _totalCollectionProjection = 0;
  double _avgAchievementPercent = 0.0; // Added missing declaration

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_collections.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        _api.fetchCollectionReports(limit: 50),
        _api.fetchProjectionReports(limit: 50),
        _api.fetchOutstandingReports(limit: 50),
        _api.fetchProjectionVsActual(limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _collections = results[0] as List<CollectionReport>;
          _projections = results[1] as List<ProjectionReport>;
          _outstandings = results[2] as List<OutstandingReport>; // Fixed bug: was assigning to _projections
          _comparisons = results[3] as List<ProjectionVsActualReport>;
          _calculateStats();
          _isLoading = false;
          _error = null;
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

    // Added missing calculation for outstanding
    _totalOutstanding = _outstandings.fold(0.0, (sum, item) {
      final v = item.pendingAmt;
      return sum + (v.isFinite ? v : 0.0);
    });

    if (_comparisons.isNotEmpty) {
      final totalPercent = _comparisons.fold(
        0.0,
        (sum, item) => sum + item.percent,
      );
      _avgAchievementPercent = totalPercent / _comparisons.length;
    }
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

    if (_isLoading && _collections.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: kBankPrimary),
      );
    }

    if (_error != null && _collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: kExpenseRed)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBankSurfaceLight,
              ),
              child: const Text("Retry", style: TextStyle(color: kTextWhite)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBankBg,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: kBankPrimary,
        backgroundColor: kBankSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "JUD-JSB Admin Overview",
                          style: TextStyle(
                            color: kTextWhite,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBankSurfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBorderColor.withOpacity(0.5)),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: kTextWhite,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 2. MAIN KPI: COLLECTIONS ---
              InkWell(
                onTap: () => widget.onNavigate(1, initialTab: 0),
                borderRadius: BorderRadius.circular(24),
                child: _buildBigCard(
                  title: "TOTAL COLLECTIONS",
                  value: safeCurrency(currencyCompact, _totalCollection),
                  subtitle: "Realized Revenue (Last 50)",
                  color1: const Color(0xFF4361EE), // Royal Blue
                  color2: const Color(0xFF3A0CA3), // Deep Blue
                  chart: _buildSparkline(
                    _collections.map((e) => e.amount).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. SECONDARY KPI: PROJECTIONS ---
              InkWell(
                onTap: () => widget.onNavigate(1, initialTab: 1),
                borderRadius: BorderRadius.circular(24),
                child: _buildBigCard(
                  title: "TOTAL PROJECTIONS",
                  value: safeCurrency(
                    currencyCompact,
                    _totalCollectionProjection,
                  ),
                  subtitle: "Projected Collections (Last 50)",
                  color1: const Color(0xFF7209B7), // Purple
                  color2: const Color(0xFFB5179E), // Magenta
                  chart: _buildSparkline(
                    _projections.map((e) => e.collectionAmount ?? 0).toList(),
                  ),
                  extraValue:
                      "${safeIntLabel(_totalOrderProjection)} MT Orders",
                ),
              ),

              const SizedBox(height: 20),

              // --- 4. CARD 3: OUTSTANDING ---
              InkWell(
                // Routing to index 2 (Outstanding tab) in the InsightsPage
                onTap: () => widget.onNavigate(1, initialTab: 2),
                borderRadius: BorderRadius.circular(24),
                child: _buildBigCard(
                  title: "TOTAL OUTSTANDING",
                  value: safeCurrency(currencyCompact, _totalOutstanding),
                  subtitle: "Pending Balance (Last 50)",
                  color1: Colors.orange.shade700, 
                  color2: Colors.deepOrangeAccent,
                  chart: _buildSparkline(
                    _outstandings.map((e) => e.pendingAmt).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // --- 5. CARD 4: COMPARISON ANALYTICS --- (will implement later)
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(24),
              //   ),
              //   child: _buildBigCard(
              //     title: "COMPARISON ANALYTICS",
              //     value: "${_avgAchievementPercent.toStringAsFixed(1)}%",
              //     subtitle: "Avg. Target Achievement",
              //     color1: const Color(0xFF00B4D8), // Cyan
              //     color2: const Color(0xFF0077B6), // Ocean Blue
              //     chart: _buildSparkline(
              //       _comparisons
              //           .map((e) => e.percent.isFinite ? e.percent : 0.0)
              //           .toList(),
              //     ),
              //   ),
              // ),

              // Extra space at bottom for scrolling nicely
              const SizedBox(height: 40),
            ],
          ),
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
      height: 220,
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
            color: color1.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 14,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              if (extraValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    extraValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 40, child: chart),
        ],
      ),
    );
  }

  Widget _buildSparkline(List<double> values) {
    if (values.isEmpty) return const SizedBox();

    final safeValues = values.map((v) => v.isFinite ? v : 0.0).toList();
    // Take last 15 points for a smoother sparkline in card
    final recent = safeValues.take(15).toList().reversed.toList();

    if (recent.isEmpty) return const SizedBox();

    final minY = recent.reduce((a, b) => a < b ? a : b);
    final maxY = recent.reduce((a, b) => a > b ? a : b);

    // Prevent chart crash if flat line
    final double range = maxY - minY;
    final double safeMinY = range == 0 ? minY - 1 : minY;
    final double safeMaxY = range == 0 ? maxY + 1 : maxY;

    final spots = recent
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: safeMinY,
        maxY: safeMaxY,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: Colors.white.withOpacity(0.8),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}