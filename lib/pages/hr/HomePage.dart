// lib/pages/hr/HomePage.dart

import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../../models/hr_reports_model.dart';
import '../../api/api_service.dart';
import 'ProfilePage.dart';
import 'subPages/vacanciesList.dart';
import 'actions/topPerformingEmployees.dart';
import 'actions/newInterviews.dart';

class HRHomePage extends StatefulWidget {
  final User user;
  final String deptName;

  const HRHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  @override
  State<HRHomePage> createState() => _HRHomePageState();
}

class _HRHomePageState extends State<HRHomePage> with SingleTickerProviderStateMixin {
  // Theme Colors
  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);

  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  HrReport? _latestReport;
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

  List<HrInterview> _allInterviews = [];
  List<HrPerformer> _topPerformers = [];
  List<HrPerformer> _bottomPerformers = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.fetchLatestHrReport(),
        _apiService.fetchManualHrData(),
      ]);

      if (mounted) {
        setState(() {
          _latestReport = results[0] as HrReport?;
          
          final manualData = results[1] as Map<String, dynamic>;
          
          // Map the aggregated JSON lists to your Dart models
          _allInterviews = (manualData['interviews'] as List).map((i) => HrInterview.fromJson(i)).toList();
          _topPerformers = (manualData['topPerformers'] as List).map((p) => HrPerformer.fromJson(p)).toList();
          _bottomPerformers = (manualData['bottomPerformers'] as List).map((p) => HrPerformer.fromJson(p)).toList();
          
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
            Tab(text: "Vacancies"),
            Tab(text: "Top Employees"),
            Tab(text: "Interviews"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Vacancies (Read-Only Data from MS Graph)
          VacanciesListTab(
            vacancies: _latestReport?.vacancies ?? [],
            reportDate: _latestReport?.reportDate ?? 'N/A',
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadData,
          ),
          TopPerformingEmployeesTab(
            topPerformers: _topPerformers,       
            bottomPerformers: _bottomPerformers, 
            onRefresh: _loadData, 
          ),
          NewInterviewsTab(
            interviews: _allInterviews,          
            onRefresh: _loadData,
          ),
        ],
      ),
    );
  }
}