// lib/listView/outstandingListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/outstandingReports_model.dart';

class OutstandingListView extends StatelessWidget {
  final List<OutstandingReport> outstandingReports;
  final Function(OutstandingReport)? onTap; // 1. Added interaction callback

  const OutstandingListView({
    super.key, 
    required this.outstandingReports,
    this.onTap,
  });

  // 2. Helper to find the most "severe" aging bucket for the subtitle
  Map<String, dynamic> _getHighestAging(OutstandingReport item) {
    // Checks strictly from worst case to best case
    if (item.greaterThan90Days > 0) return {'label': '>90 Days', 'amt': item.greaterThan90Days, 'critical': true};
    if (item.days75To90 > 0) return {'label': '75-90 Days', 'amt': item.days75To90, 'critical': true};
    if (item.days60To75 > 0) return {'label': '60-75 Days', 'amt': item.days60To75, 'critical': true};
    if (item.days45To60 > 0) return {'label': '45-60 Days', 'amt': item.days45To60, 'critical': false};
    // Default fallback
    return {'label': 'Pending', 'amt': item.pendingAmt, 'critical': false};
  }

  @override
  Widget build(BuildContext context) {
    if (outstandingReports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No outstanding reports found for this selection.",
            style: TextStyle(color: kTextGrey),
          ),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outstandingReports.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: kBorderColor),
      itemBuilder: (context, index) {
        final item = outstandingReports[index];
        final isOverdue = item.isOverdue;
        
        // Calculate the specific aging bucket to show in subtitle
        final agingInfo = _getHighestAging(item);

        // --- SMART NAME LOGIC ---
        String titleText;
        bool isUnverified = false;

        // Priority 1: Verified Database Name
        if (item.dealerPartyName != null && item.dealerPartyName!.isNotEmpty) {
          titleText = item.dealerPartyName!;
        } 
        // Priority 2: Raw/Temp Name (from Excel)
        else if (item.tempDealerName != null && item.tempDealerName!.isNotEmpty) {
          titleText = item.tempDealerName!; 
          isUnverified = true;
        } 
        // Priority 3: Dealer Code
        else if (item.dealerCode != null && item.dealerCode!.isNotEmpty) {
          titleText = item.dealerCode!;
          isUnverified = true;
        }
        // Priority 4: Fallback
        else {
          titleText = item.isAccountJsbJud 
              ? "Unverified JSB Account" 
              : "Unverified JUD Account";
          isUnverified = true;
        }

        // --- VISUAL STYLING ---
        final Color iconColor;
        final Color bgColor;
        final IconData iconData;
        
        if (isUnverified) {
          iconColor = Colors.amber;
          bgColor = Colors.amber.withOpacity(0.1);
          iconData = Icons.question_mark_rounded;
        } else if (isOverdue) {
          iconColor = Colors.redAccent;
          bgColor = Colors.redAccent.withOpacity(0.1);
          iconData = Icons.warning_amber_rounded;
        } else {
          iconColor = kBankPrimary;
          bgColor = kBankPrimary.withOpacity(0.1);
          iconData = Icons.account_balance_wallet_rounded;
        }

        final amountColor = isOverdue ? Colors.redAccent : Colors.orangeAccent;

        return ListTile(
          onTap: () => onTap?.call(item), // Trigger callback
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: bgColor,
            radius: 20,
            child: Icon(
              iconData,
              color: iconColor,
              size: 18,
            ),
          ),
          title: Text(
            titleText,
            style: TextStyle(
              color: isUnverified ? kTextGrey : kTextWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontStyle: isUnverified ? FontStyle.italic : FontStyle.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // 3. Aging Breakdown Row (New Feature)
              Row(
                children: [
                  if (agingInfo['critical']) 
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.access_time_filled, color: Colors.redAccent, size: 12),
                    ),
                  Text(
                    "${agingInfo['label']}: ${currency.format(agingInfo['amt'])}",
                    style: TextStyle(
                      color: agingInfo['critical'] ? Colors.redAccent : kTextGrey,
                      fontSize: 11,
                      fontWeight: agingInfo['critical'] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Report Date
              Text(
                item.reportDate != null
                    ? "As of: ${item.reportDate}" // Assumes YYYY-MM-DD string
                    : "Date unavailable",
                style: const TextStyle(color: kTextGrey, fontSize: 10),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.pendingAmt),
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kBankSurfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isOverdue
                        ? Colors.redAccent.withOpacity(0.5)
                        : kBorderColor,
                  ),
                ),
                child: Text(
                  item.zone ?? (item.isAccountJsbJud ? "JSB" : "JUD"),
                  style: TextStyle(
                    color: isOverdue ? Colors.redAccent : kTextGrey,
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