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
        // Determine primary dealer name (Collection dealer takes precedence if present, else Order dealer)
        final dealerName = item.collectionDealerName ?? item.orderDealerName ?? "Unknown Dealer";
        
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
              Text(
                item.collectionAmount != null ? currency.format(item.collectionAmount) : "-",
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