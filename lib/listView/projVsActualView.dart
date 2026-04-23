import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:adminapp/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/projectionVsActualReports_model.dart';

class ProjVsActualView extends StatefulWidget {
  const ProjVsActualView({super.key});

  @override
  State<ProjVsActualView> createState() => _ProjVsActualViewState();
}
class _ProjVsActualViewState extends State<ProjVsActualView> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<ProjectionVsActualReport> _reports = [];

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _surfaceSoft = Color(0xFF232323);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  String safeFixed(double v, {int digits = 1}) {
    if (!v.isFinite) return "0.0";
    return v.toStringAsFixed(digits);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _api.fetchProjectionVsActual(limit: 50);
      if (mounted) {
        setState(() {
          _reports = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Comparison Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text(
          "Comparison Analytics",
          style: TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textGrey,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _primaryAccent,
              ),
            )
          : _reports.isEmpty
              ? const Center(
                  child: Text(
                    "No comparison data available",
                    style: TextStyle(color: _textGrey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reports.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildComparisonCard(_reports[index]),
                ),
    );
  }

  Widget _buildComparisonCard(ProjectionVsActualReport item) {
    double orderProgress = 0.0;
    if (item.orderProjectionMt.isFinite && item.orderProjectionMt > 0) {
      final ratio =
          item.actualOrderReceivedMt / item.orderProjectionMt;
      orderProgress = ratio.isFinite
          ? ratio.clamp(0.0, 1.0)
          : 0.0;
    }

    double colProgress = 0.0;
    if (item.collectionProjection > 0) {
      colProgress =
          (item.actualCollection / item.collectionProjection)
              .clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.dealerName,
                  style: const TextStyle(
                    color: _textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.zone,
                  style: const TextStyle(
                    color: _primaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            DateFormat('dd MMM yyyy')
                .format(item.reportDate),
            style: const TextStyle(
              color: _textGrey,
              fontSize: 12,
            ),
          ),

          const Divider(
            color: _borderColor,
            height: 30,
          ),

          // --- ORDER PROGRESS ---
          _buildProgressRow(
            "Orders (MT)",
            "${safeFixed(item.actualOrderReceivedMt)} / ${safeFixed(item.orderProjectionMt)}",
            orderProgress,
            Colors.orangeAccent,
          ),

          const SizedBox(height: 16),

          // --- COLLECTION PROGRESS ---
          _buildProgressRow(
            "Collections",
            "${safeFixed(item.actualCollection)} / ${safeFixed(item.collectionProjection)}",
            colProgress,
            _successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    String valueLabel,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textGrey,
                fontSize: 13,
              ),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                color: _textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _surfaceSoft,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}