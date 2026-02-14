// lib/listView/outstandingListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/outstandingReports_model.dart';

class OutstandingListView extends StatelessWidget {
  final List<OutstandingReport> outstandingReports;

  const OutstandingListView({super.key, required this.outstandingReports});

  @override
  Widget build(BuildContext context) {
    if (outstandingReports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No outstanding reports found for this selection.", style: TextStyle(color: kTextGrey)),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outstandingReports.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: kBorderColor),
      itemBuilder: (context, index) {
        final item = outstandingReports[index];
        final dealerName = item.dealerPartyName ?? item.dealerCode ?? "Unknown Dealer";
        final isOverdue = item.isOverdue;

        // Visual cues for overdue vs normal outstanding status
        final iconColor = isOverdue ? Colors.redAccent : Colors.orangeAccent;
        final avatarBg = isOverdue ? Colors.redAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1);
        final amountColor = isOverdue ? Colors.redAccent : Colors.orangeAccent;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: avatarBg,
            radius: 20,
            child: Icon(
              isOverdue ? Icons.warning_amber_rounded : Icons.account_balance_wallet_rounded, 
              color: iconColor, 
              size: 18
            ),
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
                item.createdAt != null 
                    ? "Updated: ${DateFormat('dd MMM yyyy').format(item.createdAt!)}" 
                    : "Date unavailable",
                style: const TextStyle(color: kTextGrey, fontSize: 11),
              ),
              if (item.securityDepositAmt > 0)
                 Text(
                  "Security Dep: ${currency.format(item.securityDepositAmt)}",
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
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kBankSurfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isOverdue ? Colors.redAccent.withOpacity(0.5) : kBorderColor)
                ),
                child: Text(
                  item.zone ?? (item.isAccountJsbJud ? "JSB/JUD" : "General"), 
                  style: TextStyle(
                    color: isOverdue ? Colors.redAccent : kTextGrey, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
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