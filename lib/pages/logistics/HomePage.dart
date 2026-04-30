// lib/pages/logistics/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../../models/logistics_reports_model.dart';
import '../../api/api_service.dart';
import 'ProfilePage.dart';
import 'subPages/cementDispatchData.dart';
import 'subPages/rawMaterialStockData.dart';
import 'subPages/transporterPaymentData.dart';

class LogisticsHomePage extends StatefulWidget {
  final User user;
  final String deptName;

  const LogisticsHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  @override
  State<LogisticsHomePage> createState() => _LogisticsHomePageState();
}

class _LogisticsHomePageState extends State<LogisticsHomePage> with SingleTickerProviderStateMixin {
  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);

  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  LogisticsReport? _latestReport;
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
      final report = await _apiService.fetchLatestLogisticsReport();
      if (mounted) {
        setState(() {
          _latestReport = report;
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
        iconTheme: const IconThemeData(color: _textWhite),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deptName,
              style: const TextStyle(color: _textWhite, fontWeight: FontWeight.bold, fontSize: 18),
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
            icon: const Icon(Icons.account_circle, color: _primaryAccent, size: 28),
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
          labelColor: _primaryAccent,
          unselectedLabelColor: _textGrey,
          indicatorColor: _primaryAccent,
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Cement Dispatch"),
            Tab(text: "Raw Material Stock"),
            Tab(text: "Transporter Payment"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CementDispatchDataTab(
            data: _latestReport?.cementDispatchData ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          RawMaterialStockDataTab(
            data: _latestReport?.rawMaterialStockData ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          TransporterPaymentDataTab(
            data: _latestReport?.transporterPaymentData ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
        ],
      ),
    );
  }
}