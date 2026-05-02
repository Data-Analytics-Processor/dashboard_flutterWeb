// lib/pages/process/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../../models/process_reports_model.dart';
import '../../api/api_service.dart';
import './ProfilePage.dart';
import 'subPages/dailyStatusReports.dart';
import 'subPages/closingStock.dart';
import 'subPages/coalConsumption.dart';
import 'subPages/targetAchievement.dart';

class ProcessHomePage extends StatefulWidget {
  final User user;
  final String deptName;

  const ProcessHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  @override
  State<ProcessHomePage> createState() => _ProcessHomePageState();
}

class _ProcessHomePageState extends State<ProcessHomePage>
    with SingleTickerProviderStateMixin {
  // --- DARK THEME COLORS ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);

  late TabController _tabController;
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  ProcessReport? _latestReport;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      final report = await _apiService.fetchLatestProcessReport();
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
              style: const TextStyle(
                  color: _textWhite, fontWeight: FontWeight.bold, fontSize: 18),
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
            icon: const Icon(Icons.account_circle,
                color: _primaryAccent, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user)),
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
            Tab(text: "Daily Status"),
            Tab(text: "Closing Stock"),
            Tab(text: "Coal Consumption"),
            Tab(text: "Target Achievement"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyStatusReportsTab(
            data: _latestReport?.dailyStatusReports ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          ClosingStockTab(
            data: _latestReport?.closingStock ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          CoalConsumptionTab(
            data: _latestReport?.coalConsumption ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          TargetAchievementTab(
            data: _latestReport?.targetAchievement ?? [],
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