// lib/pages/InsightsPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../components/featureFlags.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // For animations
import '../components/aiQuickInsightsSheet.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/outstandingReports_model.dart';
import '../listView/dealerDetailsView.dart';

class InsightsPage extends StatefulWidget {
  final int initialTabIndex;
  final Function(String)? onOpenChat;

  const InsightsPage({super.key, this.initialTabIndex = 0, this.onOpenChat});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  List<CollectionReport> _colData = [];
  List<ProjectionReport> _projData = [];
  List<OutstandingReport> _outData = [];

  // Search and Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedMonthFilter = 'All Time'; // Default historic data

  late TabController _mainTabController;
  late TabController _groupTabController;

  final List<String> _groupTabs = ["Dealer Wise", "Zone Wise", "District Wise"];

  double safe(double v) => v.isFinite ? v : 0;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _groupTabController = TabController(length: _groupTabs.length, vsync: this);

    _mainTabController.addListener(() {
      if (_mainTabController.indexIsChanging) setState(() {});
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _fetchData();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _groupTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      String? fromDateStr;
      String? toDateStr;
      
      final now = DateTime.now();
      // --- UPDATED DATE FILTER LOGIC ---
      if (_selectedMonthFilter == 'Last 24 Hours') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(hours: 24)));
        toDateStr = DateFormat('yyyy-MM-dd').format(now);
      } else if (_selectedMonthFilter == 'Last 48 Hours') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(hours: 48)));
        toDateStr = DateFormat('yyyy-MM-dd').format(now);
      } else if (_selectedMonthFilter == 'Last 7 Days') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
        toDateStr = DateFormat('yyyy-MM-dd').format(now);
      } else if (_selectedMonthFilter == 'This Month') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
        toDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
      } else if (_selectedMonthFilter == 'Last Month') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, 1));
        toDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 0));
      } else if (_selectedMonthFilter == 'Last 3 Months') {
        fromDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 3, 1));
        toDateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
      }

      // Parallel fetching with dates applied
      final results = await Future.wait([
        _api.fetchCollectionReports(limit: 10000, fromDate: fromDateStr, toDate: toDateStr),
        _api.fetchProjectionReports(limit: 10000, fromDate: fromDateStr, toDate: toDateStr),
        _api.fetchOutstandingReports(limit: 10000, fromDate: fromDateStr, toDate: toDateStr),
      ]);

      if (mounted) {
        setState(() {
          _colData = results[0] as List<CollectionReport>;
          _projData = results[1] as List<ProjectionReport>;
          _outData = results[2] as List<OutstandingReport>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Insights Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<dynamic>> _groupData(int tabIndex, String criterion) {
    Map<String, List<dynamic>> grouped = {};

    final List<dynamic> list = tabIndex == 0
        ? _colData
        : (tabIndex == 1 ? _projData : _outData);

    for (var item in list) {
      String key = "Unknown";

      if (tabIndex == 0) {
        // COLLECTIONS
        final c = item as CollectionReport;
        if (criterion == "Dealer Wise") {
          key = c.partyName;
        } else if (criterion == "Zone Wise") {
          key = c.zone ?? "No Zone";
        } else if (criterion == "District Wise") {
          key = c.district ?? "No District";
        } 
      } else if (tabIndex == 1) {
        // PROJECTIONS
        final p = item as ProjectionReport;
        if (criterion == "Dealer Wise") {
          key = p.collectionDealerName ?? p.orderDealerName ?? "Unknown";
        } else if (criterion == "Zone Wise") {
          key = p.zone;
        } else if (criterion == "District Wise") {
          key = "N/A";
        } 
      } else {
        // OUTSTANDING
        final o = item as OutstandingReport;
        if (criterion == "Dealer Wise") {
          key = o.dealerPartyName ?? o.dealerCode ?? "Unknown";
        } else if (criterion == "Zone Wise") {
          key = o.zone ?? "No Zone";
        } else if (criterion == "District Wise") {
          key = "N/A";
        } 
      }

      // Filter logic applied here
      if (_searchQuery.isNotEmpty &&
          !key.toLowerCase().contains(_searchQuery)) {
        continue;
      }

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final int tabIndex = _mainTabController.index;

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
            Tab(text: "OUTSTANDING"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: kBankPrimary,
        backgroundColor: kBankSurface,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kBankPrimary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. KPI & Charts (Only show if not searching to reduce clutter)
                    if (_searchQuery.isEmpty) ...[
                      _buildAnalysisHeader(tabIndex),
                      const SizedBox(height: 24),
                    ],

                    // 2. Search Bar & Date Filter Row
                    Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 12),
                        _buildMonthFilter(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Sub Tabs (Filters)
                    TabBar(
                      controller: _groupTabController,
                      isScrollable: true,
                      labelColor: kBankPrimary,
                      unselectedLabelColor: kTextGrey,
                      indicatorColor: kBankPrimary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: _groupTabs.map((t) => Tab(text: t)).toList(),
                      onTap: (index) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // 4. The Data List
                    _buildGroupedList(tabIndex),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMonthFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonthFilter,
          dropdownColor: kBankSurface,
          icon: const Icon(Icons.calendar_month_rounded, color: kBankPrimary, size: 20),
          style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 13),
          items: [
            'All Time', 
            'Last 24 Hours', 
            'Last 48 Hours', 
            'Last 7 Days', 
            'This Month', 
            'Last Month', 
            'Last 3 Months'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedMonthFilter = val;
              });
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAnalysisHeader(int tabIndex) {
    double total = 0.0;
    String title = "";
    List<Color> gradientColors = [];
    int recordCount = 0;

    // Dynamic header logic based on the selected tab
    if (tabIndex == 0) {
      total = _colData.fold(0.0, (s, e) => s + safe(e.amount));
      title = "Total Collected";
      gradientColors = [kBankPrimary, kBankAccent];
      recordCount = _colData.length;
    } else if (tabIndex == 1) {
      total = _projData.fold(0.0, (s, e) => s + safe(e.collectionAmount ?? 0));
      title = "Total Projected";
      gradientColors = [Colors.deepPurple, Colors.purpleAccent];
      recordCount = _projData.length;
    } else {
      total = _outData.fold(0.0, (s, e) => s + safe(e.pendingAmt));
      title = "Total Outstanding";
      gradientColors = [Colors.teal, Colors.lightGreen];
      recordCount = _outData.length;
    }

    final currency = NumberFormat.compactCurrency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 1,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "across $recordCount records",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: kTextWhite),
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded, color: kTextGrey),
          hintText: "Search dealer, zone, user...",
          hintStyle: TextStyle(color: kTextGrey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGroupedList(int tabIndex) {
    final currentTab = _groupTabs[_groupTabController.index];
    final groupedData = _groupData(tabIndex, currentTab);

    if (groupedData.isEmpty) {
      // --- POLISHED EMPTY STATE ---
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: kBankSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: kTextGrey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "No results found.",
                style: TextStyle(color: kTextGrey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final sortedKeys = groupedData.keys.toList()
      ..sort((a, b) {
        double getSum(List<dynamic> list) => list.fold(0.0, (s, i) {
          if (tabIndex == 0) return s + (i as CollectionReport).amount;
          if (tabIndex == 1) {
            return s + ((i as ProjectionReport).collectionAmount ?? 0);
          }
          return s + ((i as OutstandingReport).pendingAmt);
        });
        return getSum(groupedData[b]!).compareTo(getSum(groupedData[a]!));
      });

    // --- STAGGERED ANIMATION LIMITER ---
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final key = sortedKeys[index];
          final items = groupedData[key]!;

          double total = 0.0;
          if (tabIndex == 0) {
            total = items.fold(
              0.0,
              (s, i) => s + safe((i as CollectionReport).amount),
            );
          } else if (tabIndex == 1) {
            total = items.fold(
              0.0,
              (s, i) => s + safe((i as ProjectionReport).collectionAmount ?? 0),
            );
          } else {
            total = items.fold(
              0.0,
              (s, i) => s + safe((i as OutstandingReport).pendingAmt),
            );
          }

          final initial = key.isNotEmpty ? key[0].toUpperCase() : "?";

          // --- ITEM ANIMATION CONFIG ---
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      if (currentTab == "Dealer Wise") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DealerDetailsView(
                              dealerName: key,
                              collections: tabIndex == 0
                                  ? items.cast<CollectionReport>()
                                  : [],
                              projections: tabIndex == 1
                                  ? items.cast<ProjectionReport>()
                                  : [],
                              outstanding: tabIndex == 2
                                  ? items.cast<OutstandingReport>()
                                  : [],
                            ),
                          ),
                        );
                      }
                    },
                    // --- LONG PRESS AI TRIGGER ---
                    onLongPress: () {
                      HapticFeedback.mediumImpact();

                      // 1. CHECK THE MASTER SWITCH FIRST
                      if (!FeatureFlags.enableAiAssistant) {
                        return; 
                      }

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AiQuickInsightsSheet(
                            entityName: key,
                            entityType: currentTab, // Passes "Zone Wise", etc.
                            collections: tabIndex == 0
                                ? items.cast<CollectionReport>()
                                : [],
                            projections: tabIndex == 1
                                ? items.cast<ProjectionReport>()
                                : [],
                            outstanding: tabIndex == 2
                                ? items.cast<OutstandingReport>()
                                : [],
                            onOpenChat: widget.onOpenChat,
                          ),
                        );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kBankSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kBorderColor.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // --- HERO ANIMATION TAG ---
                          Hero(
                            tag: 'avatar_$key',
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: kBankSurfaceLight,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: kBankPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    color: kTextWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${items.length} records",
                                  style: const TextStyle(
                                    color: kTextGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currency.format(total),
                                style: const TextStyle(
                                  color: kTextWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (currentTab == "Dealer Wise")
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    "View >",
                                    style: TextStyle(
                                      color: kBankPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}