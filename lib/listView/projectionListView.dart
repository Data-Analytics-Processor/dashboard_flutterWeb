// lib/listView/projectionListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/projectionReports_model.dart';

class ProjectionListView extends StatelessWidget {
  final List<ProjectionReport> projections;

  const ProjectionListView({super.key, required this.projections});

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No projections found for this selection.", style: TextStyle(color: kTextGrey)),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projections.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: kBorderColor),
      itemBuilder: (context, index) {
        final item = projections[index];

        // 🔥 FIX: Check for Empty Strings ("") too, not just Null.
        // Priority: Collection Dealer -> Order Dealer -> Unknown
        String dealerName = "Unknown Dealer";
        
        if (item.collectionDealerName != null && item.collectionDealerName!.trim().isNotEmpty) {
          dealerName = item.collectionDealerName!;
        } else if (item.orderDealerName != null && item.orderDealerName!.trim().isNotEmpty) {
          dealerName = item.orderDealerName!;
        }
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            radius: 20,
            child: const Icon(Icons.show_chart_rounded, color: Colors.deepPurpleAccent, size: 18),
          ),
          title: Text(
            dealerName,
            style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${DateFormat('dd MMM').format(item.reportDate)} • ${item.institution}",
                style: const TextStyle(color: kTextGrey, fontSize: 11),
              ),
              if (item.orderQtyMt != null && item.orderQtyMt! > 0)
                 Text(
                  "Order Plan: ${item.orderQtyMt} MT",
                  style: const TextStyle(color: kTextGrey, fontSize: 10),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Only show amount if it exists and is greater than 0
              Text(
                (item.collectionAmount != null && item.collectionAmount! > 0) 
                    ? currency.format(item.collectionAmount) 
                    : "-",
                style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kBankSurfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: kBorderColor)
                ),
                child: Text(
                  item.zone, 
                  style: const TextStyle(color: kTextGrey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}