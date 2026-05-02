// lib/pages/accounts/HomePage.dart
import 'package:flutter/material.dart';
import '../../models/users_model.dart';
import '../../models/accounts_reports_model.dart';
import '../../api/api_service.dart';
import './ProfilePage.dart';
import '../../components/data_table_reusable.dart'; 

class AccountsHomePage extends StatefulWidget {
  final User user;
  final String deptName;

  const AccountsHomePage({
    super.key,
    required this.user,
    required this.deptName,
  });

  @override
  State<AccountsHomePage> createState() => _AccountsHomePageState();
}

class _AccountsHomePageState extends State<AccountsHomePage> {
  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);

  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  AccountsReport? _latestReport;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await _apiService.fetchLatestAccountsReport();
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

  // A helper to format JSON keys (e.g., 'collectionTarget' -> 'Collection Target')
  String _formatKey(String key) {
    if (key.isEmpty) return '';
    final text = key
        .replaceAll(RegExp(r'(?<=[a-z])[A-Z]'), r' $0')
        .replaceAll('_', ' ');
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryAccent));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              "Failed to load data\n$_errorMessage",
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryAccent),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    if (_latestReport == null || _latestReport!.accountsDashboardData.isEmpty) {
      return const Center(
        child: Text("No Accounts Dashboard data found.", style: TextStyle(color: _textGrey, fontSize: 16)),
      );
    }

    final data = _latestReport!.accountsDashboardData;
    
    // Dynamically pull column headers from the first row's JSON keys
    final firstRowKeys = data.first.values.keys.toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _primaryAccent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: ReusableDataTable<AccountsDashboardRow>(
          title: "Accounts Dashboard",
          subtitle: "As of: ${_latestReport!.reportDate}",
          columns: firstRowKeys.map((key) => _formatKey(key)).toList(),
          data: data,
          buildCells: (row) {
            return firstRowKeys.map((key) {
              final cellValue = row.values[key];
              
              // Handle nested maps/arrays gracefully if your parser left them unflattened
              final displayValue = (cellValue is Map || cellValue is List) 
                  ? 'JSON Object' 
                  : cellValue?.toString() ?? '-';

              return DataCell(
                Text(
                  displayValue,
                  style: key.toLowerCase().contains("date") 
                      ? const TextStyle(fontWeight: FontWeight.w600, color: _textWhite)
                      : const TextStyle(color: _textGrey),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
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
      ),
      body: _buildBody(),
    );
  }
}