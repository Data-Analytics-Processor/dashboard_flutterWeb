// lib/pages/InsightsPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../listView/dealerDetailsView.dart';

class InsightsPage extends StatefulWidget {
  final int initialTabIndex; 

  const InsightsPage({super.key, this.initialTabIndex = 0});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  List<CollectionReport> _colData = [];
  List<ProjectionReport> _projData = [];
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late TabController _mainTabController; 
  late TabController _groupTabController; 

  final List<String> _groupTabs = [
    "Dealer Wise",
    "Zone Wise",
    "District Wise",
    "User Wise",
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
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
      final cData = await _api.fetchCollectionReports(limit: 100);
      final pData = await _api.fetchProjectionReports(limit: 100);
      
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

  Map<String, List<dynamic>> _groupData(bool isCollection, String criterion) {
    Map<String, List<dynamic>> grouped = {};
    final list = isCollection ? _colData : _projData;

    for (var item in list) {
      String key = "Unknown";
      if (isCollection) {
        final c = item as CollectionReport;
        if (criterion == "Dealer Wise") {key = c.partyName;}
        else if (criterion == "Zone Wise") {key = c.zone ?? "No Zone";}
        else if (criterion == "District Wise") {key = c.district ?? "No District";}
        else if (criterion == "User Wise") {key = c.salesPromoterName ?? "Unknown User";}
      } else {
        final p = item as ProjectionReport;
        if (criterion == "Dealer Wise") {key = p.collectionDealerName ?? p.orderDealerName ?? "Unknown";}
        else if (criterion == "Zone Wise") {key = p.zone;}
        else if (criterion == "District Wise") {key = "N/A";}
        else if (criterion == "User Wise") {key = "User ${p.salesPromoterUserId ?? 'N/A'}";}
      }
      
      // Filter logic applied here
      if (_searchQuery.isNotEmpty && !key.toLowerCase().contains(_searchQuery)) {
        continue;
      }

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isCollection = _mainTabController.index == 0;

    return Scaffold(
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        title: const Text("Analysis Studio", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: kBankPrimary,
          labelColor: kTextWhite,
          unselectedLabelColor: kTextGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [Tab(text: "COLLECTIONS"), Tab(text: "PROJECTIONS")],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: kBankPrimary,
        backgroundColor: kBankSurface,
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kBankPrimary))
        : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KPI & Charts (Only show if not searching to reduce clutter)
                if (_searchQuery.isEmpty) ...[
                   _buildAnalysisHeader(isCollection),
                   const SizedBox(height: 24),
                ],

                // 2. Search Bar
                _buildSearchBar(),
                const SizedBox(height: 20),

                // 3. Sub Tabs (Filters)
                TabBar(
                  controller: _groupTabController,
                  isScrollable: true,
                  labelColor: kBankPrimary,
                  unselectedLabelColor: kTextGrey,
                  indicatorColor: kBankPrimary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: _groupTabs.map((t) => Tab(text: t)).toList(),
                  onTap: (index) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // 4. The Data List
                _buildGroupedList(isCollection),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildAnalysisHeader(bool isCollection) {
    // Simple KPI Summary just to give context before the list
    double total = isCollection 
      ? _colData.fold(0, (s, e) => s + e.amount)
      : _projData.fold(0, (s, e) => s + (e.collectionAmount ?? 0));
      
    final currency = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN', decimalDigits: 1);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCollection 
            ? [kBankPrimary, kBankAccent] 
            : [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: kBankPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCollection ? "Total Collected" : "Total Projected",
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
             currency.format(total),
             style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "across ${_colData.length + _projData.length} records",
             style: const TextStyle(color: Colors.white60, fontSize: 12),
          )
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

  Widget _buildGroupedList(bool isCollection) {
    final currentTab = _groupTabs[_groupTabController.index];
    final groupedData = _groupData(isCollection, currentTab);
    
    if (groupedData.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No results found.", style: TextStyle(color: kTextGrey)),
      ));
    }

    final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    // Sorting by total value
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

        double total = isCollection 
            ? items.fold(0.0, (s, i) => s + (i as CollectionReport).amount)
            : items.fold(0.0, (s, i) => s + ((i as ProjectionReport).collectionAmount ?? 0));
            
        // Initial for Avatar
        final initial = key.isNotEmpty ? key[0].toUpperCase() : "?";

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
               // Only navigate to drill-down if we are in "Dealer Wise" mode
               if (currentTab == "Dealer Wise") {
                 Navigator.push(context, MaterialPageRoute(
                   builder: (context) => DealerDetailsView(
                     dealerName: key,
                     collections: isCollection ? items.cast<CollectionReport>() : [],
                     projections: !isCollection ? items.cast<ProjectionReport>() : [],
                   )
                 ));
               }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBankSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor.withOpacity(0.5)),
                boxShadow: [
                   BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: kBankSurfaceLight,
                    child: Text(initial, style: const TextStyle(color: kBankPrimary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(key, style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("${items.length} records", style: const TextStyle(color: kTextGrey, fontSize: 11)),
                      ],
                    ),
                  ),
                  
                  // Trailing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(currency.format(total), style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                      // Only show "View >" if drill down is available
                      if (currentTab == "Dealer Wise")
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text("View >", style: TextStyle(color: kBankPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}