// lib/pages/sales-marketing/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../../models/sales_reports_model.dart';
import '../../api/api_service.dart';
import 'ProfilePage.dart';

// Import our new sub-pages
import 'subPages/salesData.dart';
import 'subPages/collectionData.dart';
import 'actions/nonTradePriceApproval.dart';

class SalesHomePage extends StatefulWidget {
  final User user;
  final String deptName;

  const SalesHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  @override
  State<SalesHomePage> createState() => _SalesHomePageState();
}

class _SalesHomePageState extends State<SalesHomePage> with SingleTickerProviderStateMixin {
  // Theme Colors
  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);

  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  SalesReport? _latestReport;
  List<NonTradeApproval> _nonTradeApprovals = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parallel fetch for speed
      final results = await Future.wait([
        _apiService.fetchLatestSalesReport(),
        _apiService.fetchManualSalesData(),
      ]);

      if (mounted) {
        setState(() {
          _latestReport = results[0] as SalesReport?;
          _nonTradeApprovals = results[1] as List<NonTradeApproval>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deptName,
              style: const TextStyle(color: _textBlack, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Welcome back, ${widget.user.email.split('@')[0]}",
              style: const TextStyle(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _textGrey),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: _primaryNavy, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryNavy,
          unselectedLabelColor: _textGrey,
          indicatorColor: _primaryNavy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Sales Report"),
            Tab(text: "Collections"),
            Tab(text: "Non-Trade Prices"),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryNavy));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text("Failed to load data\n$_errorMessage", textAlign: TextAlign.center, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryNavy),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // TAB 1: Sales Data (Automated)
        SalesDataTab(
          salesData: _latestReport?.salesData ?? [],
          reportDate: _latestReport?.reportDate ?? 'N/A',
        ),
        
        // TAB 2: Collection Data (Automated)
        CollectionDataTab(
          collectionData: _latestReport?.collectionData ?? [],
          reportDate: _latestReport?.reportDate ?? 'N/A',
        ),

        // TAB 3: Non-Trade Approvals (Manual)
        NonTradeApprovalTab(
          approvals: _nonTradeApprovals,
          onRefresh: _loadData,
        ),
      ],
    );
  }
}