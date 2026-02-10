import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
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
      backgroundColor: kBankBg,
      appBar: AppBar(
        backgroundColor: kBankBg,
        elevation: 0,
        title: const Text(
          "Comparison Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kBankPrimary))
          : _reports.isEmpty
          ? const Center(
              child: Text(
                "No comparison data available",
                style: TextStyle(color: kTextGrey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _buildComparisonCard(_reports[index]),
            ),
    );
  }

  Widget _buildComparisonCard(ProjectionVsActualReport item) {
    // Calculate Percentages for Progress Bars (Clamp to 0.0 - 1.0)
    double orderProgress = 0.0;
    if (item.orderProjectionMt.isFinite && item.orderProjectionMt > 0) {
      final ratio = item.actualOrderReceivedMt / item.orderProjectionMt;
      orderProgress = ratio.isFinite ? ratio.clamp(0.0, 1.0) : 0.0;
    }

    double colProgress = 0.0;
    if (item.collectionProjection > 0) {
      colProgress = (item.actualCollection / item.collectionProjection).clamp(
        0.0,
        1.0,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.dealerName,
                  style: const TextStyle(
                    color: kTextWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kBankSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.zone,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy').format(item.reportDate),
            style: const TextStyle(color: kTextGrey, fontSize: 12),
          ),

          const Divider(color: kBorderColor, height: 30),

          // 1. Order Comparison Row
          _buildProgressRow(
            "Orders (MT)",
            "${safeFixed(item.actualOrderReceivedMt)} / ${safeFixed(item.orderProjectionMt)}",
            orderProgress,
            Colors.orangeAccent,
          ),

          const SizedBox(height: 16),

          // 2. Collection Comparison Row
          _buildProgressRow(
            "Collections",
            "${safeFixed(item.actualCollection)} / ${safeFixed(item.collectionProjection)}",
            colProgress,
            kSuccessGreen,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: kTextGrey, fontSize: 13)),
            Text(
              valueLabel,
              style: const TextStyle(
                color: kTextWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: kBankSurfaceLight,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
