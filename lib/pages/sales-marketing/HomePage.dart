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
class _SalesHomePageState extends State<SalesHomePage>
    with SingleTickerProviderStateMixin {
  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  // static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  // static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

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
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deptName,
              style: const TextStyle(
                color: _textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Welcome back, ${widget.user.email.split('@')[0]}",
              style: const TextStyle(
                color: _textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _textGrey),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle,
                color: _primaryAccent, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(user: widget.user),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryAccent,
          unselectedLabelColor: _textGrey,
          indicatorColor: _primaryAccent,
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
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryAccent,
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: _bgDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: _errorRed, size: 48),
              const SizedBox(height: 16),
              Text(
                "Failed to load data\n$_errorMessage",
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                ),
                child: const Text("Retry",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        SalesDataTab(
          salesData: _latestReport?.salesData ?? [],
          reportDate: _latestReport?.reportDate ?? 'N/A',
        ),
        CollectionDataTab(
          collectionData:
              _latestReport?.collectionData ?? [],
          reportDate: _latestReport?.reportDate ?? 'N/A',
        ),
        NonTradeApprovalTab(
          approvals: _nonTradeApprovals,
          onRefresh: _loadData,
        ),
      ],
    );
  }
}