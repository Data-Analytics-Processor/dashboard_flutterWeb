// lib/pages/HomePage.dart
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

  // Aggregated Stats
  double _totalCollection = 0;
  double _totalCollectionProjection = 0;
  double _jsbOutstanding = 0;
  double _judOutstanding = 0;
  DateTime? _lastCollectionDate;

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
        _api.fetchOutstandingReports(limit: 100), // Catch more overdues
        _api.fetchProjectionVsActual(limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _collections = results[0] as List<CollectionReport>;
          _projections = results[1] as List<ProjectionReport>;
          _outstandings = results[2] as List<OutstandingReport>;
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

    _totalCollectionProjection = _projections.fold(0.0, (sum, item) {
      final v = item.collectionAmount ?? 0.0;
      return sum + (v.isFinite ? v : 0.0);
    });

    // Separate Outstanding by Institution
    _jsbOutstanding = _outstandings.where((e) => e.isAccountJsbJud).fold(0.0, (sum, item) {
      final v = item.pendingAmt;
      return sum + (v.isFinite ? v : 0.0);
    });

    _judOutstanding = _outstandings.where((e) => !e.isAccountJsbJud).fold(0.0, (sum, item) {
      final v = item.pendingAmt;
      return sum + (v.isFinite ? v : 0.0);
    });

    // Get the most recent collection date
    if (_collections.isNotEmpty) {
      _lastCollectionDate = _collections
          .map((e) => e.voucherDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
  }

  String safeCompactFormat(double value) {
    if (!value.isFinite || value == 0) return "0";
    final fmt = NumberFormat.compact(locale: 'en_IN');
    String formatted = fmt.format(value);
    
    // Insert a space between numbers and the abbreviation for a cleaner look
    formatted = formatted
        .replaceAll('T', ' T')
        .replaceAll('Cr', ' Cr')
        .replaceAll('L', ' L')
        .replaceAll('K', ' K');
        
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: kBankBg, // Restored theme bg
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
              // --- 1. HEADER (Restored from your original) ---
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
              
              // --- 2. TOP ROW CARDS ---
              Row(
                children: [
                  Expanded(
                    child: _buildSquareCard(
                      title: "TOTAL\nCOLLECTION",
                      value: safeCompactFormat(_totalCollection),
                      subtitle: _lastCollectionDate != null
                          ? "Last Date of Collection: ${DateFormat('d MMM, yyyy').format(_lastCollectionDate!)}"
                          : "No recent collections",
                      borderColor: kSuccessGreen, // Cyan accent from theme
                      onTap: () => widget.onNavigate(1, initialTab: 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSquareCard(
                      title: "TOTAL\nPROJECTION",
                      value: safeCompactFormat(_totalCollectionProjection),
                      borderColor: kBankPrimary, // Royal Blue accent from theme
                      onTap: () => widget.onNavigate(1, initialTab: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 3. JSB OUTSTANDING CARD ---
              _buildWideCard(
                title: "JSB",
                label: "Total Overdue",
                value: safeCompactFormat(_jsbOutstanding),
                borderColor: kExpenseRed, // Pink/Red for overdue
                onTap: () => widget.onNavigate(1, initialTab: 2),
              ),
              const SizedBox(height: 20),

              // --- 4. JUD OUTSTANDING CARD ---
              _buildWideCard(
                title: "JUD",
                label: "Total Overdue",
                value: safeCompactFormat(_judOutstanding),
                borderColor: kExpenseRed, // Pink/Red for overdue
                onTap: () => widget.onNavigate(1, initialTab: 2),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Builder for the Square Top Cards (Neo-Bank Theme)
  Widget _buildSquareCard({
    required String title,
    required String value,
    String? subtitle,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190, 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: kBankSurface, // Themed Surface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: kTextWhite,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextGrey, // Themed Grey
                  fontSize: 10,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Builder for the Wide Bottom Cards (Neo-Bank Theme)
  Widget _buildWideCard({
    required String title,
    required String label,
    required String value,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: kBankSurface, // Themed Surface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: kTextWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: kTextGrey, // Themed Grey
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: kTextWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: kTextGrey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}