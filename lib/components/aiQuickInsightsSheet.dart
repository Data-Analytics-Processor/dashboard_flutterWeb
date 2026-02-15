// lib/components/aiQuickInsightsSheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../api/api_service.dart';
import '../models/collectionReports_model.dart';
import '../models/projectionReports_model.dart';
import '../models/outstandingReports_model.dart';

class AiQuickInsightsSheet extends StatefulWidget {
  final String entityName; // Changed from dealerName
  final String entityType; // Added this (e.g., "Dealer Wise", "Zone Wise")
  final List<CollectionReport> collections;
  final List<ProjectionReport> projections;
  final List<OutstandingReport> outstanding;
  final Function(String)? onOpenChat; 

  const AiQuickInsightsSheet({
    super.key,
    required this.entityName,
    required this.entityType,
    required this.collections,
    required this.projections,
    required this.outstanding,
    this.onOpenChat,
  });

  @override
  State<AiQuickInsightsSheet> createState() => _AiQuickInsightsSheetState();
}

class _AiQuickInsightsSheetState extends State<AiQuickInsightsSheet> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _aiResponse;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAiInsights();
  }

  Future<void> _fetchAiInsights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final double totalCollected = widget.collections.fold(0.0, (s, e) => s + e.amount);
      final double totalProjected = widget.projections.fold(0.0, (s, e) => s + (e.collectionAmount ?? 0));
      final double totalOutstanding = widget.outstanding.fold(0.0, (s, e) => s + e.pendingAmt);

      final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
      final typeStr = widget.entityType.replaceAll(' Wise', ''); // "Dealer", "Zone", or "District"

      String profileContext = "No extended profile data available.";
      
      // ONLY fetch dealer profile context if it's actually a Dealer
      if (widget.entityType == "Dealer Wise") {
        try {
          String? targetDealerCode;
          int? targetDealerId;

          if (widget.outstanding.isNotEmpty && widget.outstanding.first.dealerCode != null) {
            targetDealerCode = widget.outstanding.first.dealerCode;
          } else if (widget.collections.isNotEmpty && widget.collections.first.verifiedDealerId != null) {
            targetDealerId = widget.collections.first.verifiedDealerId;
          } else if (widget.projections.isNotEmpty && widget.projections.first.verifiedDealerId != null) {
            targetDealerId = widget.projections.first.verifiedDealerId;
          }

          if (targetDealerCode != null || targetDealerId != null) {
            final profiles = await _api.fetchVerifiedDealers(
              dealerCode: targetDealerCode,
              dealerId: targetDealerId,
              limit: 1,
            );

            if (profiles.isNotEmpty) {
              final profile = profiles.first;
              profileContext = """
              - Category: ${profile.dealerCategory ?? 'Unknown'}
              - Subdealer Status: ${profile.isSubdealer == true ? 'Yes' : 'No'}
              - Zone & Area: ${profile.zone ?? 'N/A'} / ${profile.area ?? 'N/A'}
              - Managed By (TSO/SO): ${profile.tsoName ?? 'Unknown'}
              """;
            }
          }
        } catch (e) {
          debugPrint("Profile Fetch skipped/failed: $e");
        }
      }

      // Dynamic prompt adjusting to the macro/micro level
      final String hiddenPrompt = """
        You are an expert financial analyst for a cement business. 
        Analyze this specific $typeStr: '${widget.entityName}'.
        
        ${widget.entityType == "Dealer Wise" ? "Dealer Profile Metadata:\n$profileContext\n" : ""}
        Recent Financial Snapshot:
        - Total Collected: ${currency.format(totalCollected)}
        - Total Projected Collections: ${currency.format(totalProjected)}
        - Total Outstanding/Overdue: ${currency.format(totalOutstanding)}
        
        Provide a strict 2-3 sentence summary. Tell me if the $typeStr is financially healthy, 
        and if there is a collection risk based on the outstanding vs collected ratio. 
        Do not use any markdown formatting, just plain text.
      """;

      final response = await _api.sendChat(message: hiddenPrompt);

      if (mounted) {
        setState(() {
          _aiResponse = response['response'] ?? "The AI did not return a valid response.";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("AI ERROR: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to generate AI insights. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kBankSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: kBankPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "AI Quick Insights: ${widget.entityName}",
                  style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: kTextGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: kBorderColor, height: 24),

          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else
            _buildSuccessState(),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onOpenChat != null && _aiResponse != null) {
                  final type = widget.entityType.replaceAll(' Wise', '');
                  widget.onOpenChat!("**$type Context Loaded: ${widget.entityName}**\n\n$_aiResponse");
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text("Continue in AI Analyst"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBankSurfaceLight,
                foregroundColor: kBankPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const LinearProgressIndicator(color: kBankPrimary, backgroundColor: kBankSurfaceLight),
        const SizedBox(height: 16),
        Text(
          "Analyzing historical data, collections, and outstanding balances for ${widget.entityName}...",
          style: const TextStyle(color: kTextGrey, fontStyle: FontStyle.italic, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kExpenseRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kExpenseRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: kExpenseRed),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: kExpenseRed))),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kExpenseRed),
            onPressed: _fetchAiInsights,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Text(
      _aiResponse ?? "",
      style: const TextStyle(color: kTextWhite, height: 1.5, fontSize: 14),
    );
  }
}