// lib/listView/projectionListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:adminapp/ReusableConstants/constants.dart';
import '../models/projectionReports_model.dart';
class ProjectionListView extends StatelessWidget {
  final List<ProjectionReport> projections;

  const ProjectionListView({super.key, required this.projections});

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No projections found for this selection.",
            style: TextStyle(color: _textGrey),
          ),
        ),
      );
    }

    final currency =
        NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projections.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: _borderColor),
      itemBuilder: (context, index) {
        final item = projections[index];

        // --- DEALER NAME LOGIC ---
        String dealerName = "Unknown Dealer";

        if (item.collectionDealerName != null &&
            item.collectionDealerName!.trim().isNotEmpty) {
          dealerName = item.collectionDealerName!;
        } else if (item.orderDealerName != null &&
            item.orderDealerName!.trim().isNotEmpty) {
          dealerName = item.orderDealerName!;
        }

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 10),

          // --- ICON ---
          leading: CircleAvatar(
            backgroundColor: _primaryAccent.withOpacity(0.15),
            radius: 20,
            child: const Icon(
              Icons.show_chart_rounded,
              color: _primaryAccent,
              size: 18,
            ),
          ),

          // --- TITLE ---
          title: Text(
            dealerName,
            style: const TextStyle(
              color: _textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // --- SUBTITLE ---
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${DateFormat('dd MMM').format(item.reportDate)} • ${item.institution}",
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 11,
                ),
              ),
              if (item.orderQtyMt != null && item.orderQtyMt! > 0)
                Text(
                  "Order Plan: ${item.orderQtyMt} MT",
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 10,
                  ),
                ),
            ],
          ),

          // --- TRAILING ---
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (item.collectionAmount != null &&
                        item.collectionAmount! > 0)
                    ? currency.format(item.collectionAmount)
                    : "-",
                style: const TextStyle(
                  color: _primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _borderColor),
                ),
                child: Text(
                  item.zone,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}