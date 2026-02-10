// lib/pages/InsightsPage.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../listView/collectionListView.dart';
import '../listView/projectionListView.dart';

class InsightsPage extends StatefulWidget {
  final int initialTabIndex; // 0 for Collections, 1 for Projections

  const InsightsPage({super.key, this.initialTabIndex = 0});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  List<CollectionReport> _colData = [];
  List<ProjectionReport> _projData = [];

  // Tab Controllers
  late TabController _mainTabController; // Top Level: Collection vs Projection
  late TabController _groupTabController; // Sub Level: Dealer, Zone, etc.

  final List<String> _groupTabs = [
    "Dealer Wise",
    "Zone Wise",
    "District Wise",
    "User Wise",
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _groupTabController = TabController(length: _groupTabs.length, vsync: this);

    // Add listener to rebuild when main tab changes
    _mainTabController.addListener(() {
      if (_mainTabController.indexIsChanging) setState(() {});
    });

    _fetchData();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _groupTabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InsightsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent passes a new tab index, animate to it
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      _mainTabController.animateTo(widget.initialTabIndex);
    }
  }

  Future<void> _fetchData() async {
    try {
      final cData = await _api.fetchCollectionReports(limit: 50);
      final pData = await _api.fetchProjectionReports(limit: 50);

      if (mounted) {
        setState(() {
          _colData = cData;
          _projData = pData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Insights Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Grouping Logic ---
  Map<String, List<dynamic>> _groupData(bool isCollection, String criterion) {
    Map<String, List<dynamic>> grouped = {};

    final list = isCollection ? _colData : _projData;

    for (var item in list) {
      String key = "Unknown";

      if (isCollection) {
        final c = item as CollectionReport;
        if (criterion == "Dealer Wise") {
          key = c.partyName;
        } else if (criterion == "Zone Wise") {
          key = c.zone ?? "No Zone";
        } else if (criterion == "District Wise") {
          key = c.district ?? "No District";
        } else if (criterion == "User Wise") {
          key = c.salesPromoterName ?? "Unknown User";
        }
      } else {
        final p = item as ProjectionReport;
        if (criterion == "Dealer Wise") {
          key = p.collectionDealerName ?? p.orderDealerName ?? "Unknown";
        } else if (criterion == "Zone Wise") {
          key = p.zone;
        } else if (criterion == "District Wise") {
          key = "N/A";
        } // Projections might not have District
        else if (criterion == "User Wise") {
          key = "User ${p.salesPromoterUserId ?? 'N/A'}";
        }
      }

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: kBankPrimary),
      );

    final isCollection = _mainTabController.index == 0;

    // --- Aggregations based on selected Main Tab ---
    double totalAmount = 0;
    int count = 0;
    Map<int, double> dailyMap = {};
    Map<String, double> catMap = {};

    if (isCollection) {
      totalAmount = _colData.fold(0.0, (s, i) => s + i.amount);
      count = _colData.length;
      for (var row in _colData) {
        dailyMap[row.voucherDate.day] =
            (dailyMap[row.voucherDate.day] ?? 0) + row.amount;
        catMap[row.institution] = (catMap[row.institution] ?? 0) + row.amount;
      }
    } else {
      totalAmount = _projData.fold(
        0.0,
        (s, i) => s + (i.collectionAmount ?? 0),
      );
      count = _projData.length;
      for (var row in _projData) {
        dailyMap[row.reportDate.day] =
            (dailyMap[row.reportDate.day] ?? 0) + (row.collectionAmount ?? 0);
        catMap[row.institution] =
            (catMap[row.institution] ?? 0) + (row.collectionAmount ?? 0);
      }
    }

    final avgAmount = count == 0 ? 0.0 : totalAmount / count;

    return Scaffold(
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        title: const Text(
          "Analysis Studio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: kBankPrimary,
          labelColor: kTextWhite,
          unselectedLabelColor: kTextGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "COLLECTIONS"),
            Tab(text: "PROJECTIONS"),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isCollection),
                const SizedBox(height: 24),

                // KPI Section
                _buildKPISection(
                  isMobile: isMobile,
                  total: totalAmount,
                  count: count,
                  avg: avgAmount,
                  isCollection: isCollection,
                ),
                const SizedBox(height: 24),

                // Charts
                _buildChartsSection(
                  isMobile: isMobile,
                  dailyData: dailyMap,
                  catData: catMap,
                ),
                const SizedBox(height: 32),

                // --- SUB TABS & LIST VIEW ---
                _buildSubTabsSection(isCollection),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubTabsSection(bool isCollection) {
    return Column(
      children: [
        TabBar(
          controller: _groupTabController,
          isScrollable: true,
          labelColor: kBankPrimary,
          unselectedLabelColor: kTextGrey,
          indicatorColor: kBankPrimary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: _groupTabs.map((t) => Tab(text: t)).toList(),
          onTap: (index) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _buildGroupedListView(isCollection),
      ],
    );
  }

  Widget _buildGroupedListView(bool isCollection) {
    final currentTab = _groupTabs[_groupTabController.index];
    final groupedData = _groupData(isCollection, currentTab);

    final currency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    // Sort by value descending
    final sortedKeys = groupedData.keys.toList()
      ..sort((a, b) {
        double getSum(List<dynamic> list) => list.fold(0.0, (s, i) {
          if (isCollection) return s + (i as CollectionReport).amount;
          return s + ((i as ProjectionReport).collectionAmount ?? 0);
        });
        return getSum(groupedData[b]!).compareTo(getSum(groupedData[a]!));
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final items = groupedData[key]!;

        double total = 0;
        if (isCollection) {
          total = items.fold(0.0, (s, i) => s + (i as CollectionReport).amount);
        } else {
          total = items.fold(
            0.0,
            (s, i) => s + ((i as ProjectionReport).collectionAmount ?? 0),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: kBankSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderColor),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      key,
                      style: const TextStyle(
                        color: kTextWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    currency.format(total),
                    style: TextStyle(
                      color: isCollection
                          ? kBankPrimary
                          : Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                "${items.length} Records",
                style: const TextStyle(color: kTextGrey, fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: isCollection
                      ? CollectionListView(
                          collections: items.cast<CollectionReport>(),
                        )
                      : ProjectionListView(
                          projections: items.cast<ProjectionReport>(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String safeFormat(NumberFormat fmt, double v) {
    if (!v.isFinite) return "₹0";
    return fmt.format(v);
  }

  Widget _buildKPISection({
    required bool isMobile,
    required double total,
    required int count,
    required double avg,
    required bool isCollection,
  }) {
    final currency = NumberFormat.compactCurrency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 1,
    );
    final currencySimple = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );
    final color = isCollection ? kBankPrimary : Colors.deepPurpleAccent;

    final cards = [
      _KPICard(
        title: "Total Value",
        value: safeFormat(currency, total),
        icon: Icons.account_balance_wallet,
        color: color,
      ),
      _KPICard(
        title: "Count",
        value: count.toString(),
        icon: Icons.receipt_long,
        color: Colors.orangeAccent,
      ),
      _KPICard(
        title: "Avg. Value",
        value: currencySimple.format(avg),
        icon: Icons.analytics,
        color: Colors.tealAccent,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    } else {
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

  // Charts & Header ...
  Widget _buildHeader(bool isCollection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCollection ? "Collection Insights" : "Projection Insights",
          style: const TextStyle(
            color: kTextWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCollection
              ? "Realized revenue breakdown"
              : "Planned targets breakdown",
          style: const TextStyle(color: kTextGrey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildChartsSection({
    required bool isMobile,
    required Map<int, double> dailyData,
    required Map<String, double> catData,
  }) {
    final trendChart = _ChartContainer(
      title: "Daily Trend",
      child: _SpendLineChart(dailyData: dailyData),
    );

    final catChart = _ChartContainer(
      title: "Institution Split",
      child: _CategoryBreakdown(data: catData),
    );

    if (isMobile) {
      return Column(
        children: [trendChart, const SizedBox(height: 24), catChart],
      );
    } else {
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
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Text(
                title,
                style: const TextStyle(
                  color: kTextGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: kTextWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Text(
            title,
            style: const TextStyle(
              color: kTextWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    if (dailyData.isEmpty) {
      return const Center(
        child: Text("No Data", style: TextStyle(color: kTextGrey)),
      );
    }
    final spots =
        dailyData.entries
            .map(
              (e) => FlSpot(e.key.toDouble(), e.value.isFinite ? e.value : 0.0),
            )
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty || spots.every((s) => s.y == 0)) {
      return const Center(
        child: Text("No Data", style: TextStyle(color: kTextGrey)),
      );
    }

    final ys = spots.map((s) => s.y).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      return const Center(
        child: Text("No Trend", style: TextStyle(color: kTextGrey)),
      );
    }

    return LineChart(
      LineChartData(
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (!val.isFinite) return const SizedBox();
                return Text(
                  val.toInt().toString(),
                  style: const TextStyle(color: kTextGrey, fontSize: 10),
                );
              },
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
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty)
      return const Center(
        child: Text("No Data", style: TextStyle(color: kTextGrey)),
      );

    final maxVal = sorted.first.value;

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final item = sorted[index];
        final safeValue = item.value.isFinite ? item.value : 0.0;
        final pct = (maxVal <= 0) ? 0.0 : (safeValue / maxVal).clamp(0.0, 1.0);

        final safeDisplay = item.value.isFinite ? item.value : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.key,
                    style: const TextStyle(color: kTextWhite, fontSize: 13),
                  ),

                  Text(
                    NumberFormat.compactCurrency(
                      symbol: '₹',
                      locale: 'en_IN',
                    ).format(safeDisplay),
                    style: const TextStyle(color: kTextGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: kBankSurfaceLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
